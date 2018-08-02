#!/usr/bin/perl -w
use strict;
use Getopt::Std;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - -
#Goals of script:
#Convert files from MaxBin, MetaBat, and CONCOCT for input as scaffold2bin.tsv files into DAS Tool. Contig names will be shortened to the first space.

# - - - - - U S E R    V A R I A B L E S - - - - - - - -


# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my %options=();
getopts("f:m:b:p:s:o:h", \%options);

if ($options{h})
    {   print "\n\nThe goal of this script is to prepare files for DAS Tool,\n";
        print "including: 1) to produce a contig file with simplified headers\n";
        print "(i.e. to the first space). 2) to produce the tab delimited\n";
        print "contig to bin file (format contig name<tab>bin number).\n";
        print "\nUsage example:\n";
        print "DASTool_converter.pl -m maxbin -f contigs.fasta -b bin_folder -p Sample1_maxbin_out. -s .fasta -o Sample1\n";
        print "Output files: Sample1_maxbin_scaffold2bin.tsv & Sample1_simplifiedheaders.fasta\n";
        print "\nHelp called:\nOptions:\n";
        print "-f = fasta file with complex contig names\n";
        print "-m = binning method\n";
        print "-b = folder with bins in it (no forward slash at end)\n";
        print "-p = bin prefix (i.e. stuff before bin number)\n";
        print "-s = bin suffix (i.e. stuff after bin number)\n";
        print "-o = output prefix (no binning method)\n";
	print "-h = This help message\n\n";
	die;
    }

if ($options{f} eq "")
    {die "You did not provide a fasta file with the -f option.\n\nPlease use the -h option for help.\n\n";}
if ($options{m} eq "")
    {die "You did not provide a binning method with the -m option.\n\nPlease use the -h option for help.\n\n";}
if ($options{b} eq "")
    {die "You did not provide a bin folder with the -b option.\n\nPlease use the -h option for help.\n\n";}
if ($options{p} eq "")
    {die "You did not provide a prefix name with the -p option.\nThe prefix should be all the text prior to the bin number.\n\nPlease use the -h option for help.\n\n";}
if ($options{s} eq "")
    {die "You did not provide a suffix name with the -s option.\nThe suffix should be all the text after the bin number.\n\nPlease use the -h option for help.\n\n";}
if ($options{o} eq "")
    {die "You did not provide an output prefix with the -o option.\nThis should just be the sample name.\n\nPlease use the -h option for help.\n\n";}


my %Sequences;
my %BinSeqs;
my $binprefixre = qr/$options{p}/;
my $binsuffixre = qr/$options{s}/;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
&FASTAread($options{f}, 1);

open(FOUT, ">".$options{o}."_simplifiedheaders.fasta");
foreach my $i (sort keys %Sequences)
    { print FOUT ">".$Sequences{$i}{'SHORT_HEAD'}."\n".$Sequences{$i}{'gappy-ntseq'}."\n";
    }
close(FOUT);

open(MAXOUT, ">".$options{o}."_".$options{m}."_scaffold2bin.tsv");
opendir(DIR, "$options{b}") or die "\n\nNada $options{b} you fool!!\n\n";
while (my $file = readdir(DIR))
    {	if ($file =~ m/$binsuffixre$/)
            {   $file =~ m/^$binprefixre(\d+)$binsuffixre/;
                my $bin_num = $1;
                my $dig;
                if ($bin_num <= 9) {$dig = 1;}
                if ($bin_num >= 10 && $bin_num <= 99) {$dig = 2;}
                if ($bin_num >= 100 && $bin_num <= 999) {$dig = 3;}
                if ($bin_num >= 1000 && $bin_num <= 9999) {$dig = 4;}
                if ($bin_num >= 10000) {$dig = 5;}
                %BinSeqs = ();
                &BINread($options{b}."/".$file, 5);
                foreach my $l (sort keys %BinSeqs)
                    {   print MAXOUT "$BinSeqs{$l}{'SHORT_HEAD'}"."\tbin.";
                        if($dig == 1)
                        {print MAXOUT "0000";}
                        if($dig == 2)
                        {print MAXOUT "000";}
                        if($dig == 3)
                        {print MAXOUT "00";}
                        if($dig == 4)
                        {print MAXOUT "0";}
                        print MAXOUT $bin_num."\n";
                    }
            }	
    }
close(MAXOUT);



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - S U B R O U T I N E S - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub FASTAread
{	#print "   Reading file . . . \n";
	# 1. Load FIlE . . . . . . . . . .
	$/=">";                                     # set input break string
	my $infile = $_[0];
        my $filenumber = $_[1];
	open(IN, "<$infile") or die "\n\nNADA $infile you FOOL!!!\n\n";
	my @DATA = <IN>; close(IN); shift(@DATA);	
	# 2. Parse sequence data . . . . . . . . . . . . .
	my $unid = $filenumber.100000000001;                           # string to generate unique ids
	foreach my $entry (@DATA)
	{	my @data = split('\n', $entry);
		my $seq = '';
		foreach my $i (1..$#data)
		{	$seq .= $data[$i];  }
		$seq =~ s/>//;
		$Sequences{$unid}{'HEAD'}    = $data[0];       # store header
		my @shorthead = split(' ', $data[0]);
		$Sequences{$unid}{'SHORT_HEAD'} = $shorthead[0];
		$Sequences{$unid}{'gappy-ntseq'}   = uc($seq);       # store aligned sequence
		$Sequences{$unid}{'SIZE'}    = length($seq);   # store length
		$seq =~ s/\.//;
                $seq =~ s/\-//;
                $Sequences{$unid}{'degapped-ntseq'} = uc($seq);     # store degapped sequence
                $Sequences{$unid}{'filenumber'} = $filenumber;
                $unid += 1;
	}
	$/="\n";
}

sub BINread
{	#print "   Reading file . . . \n";
	# 1. Load FIlE . . . . . . . . . .
	$/=">";                                     # set input break string
	my $infile = $_[0];
        my $filenumber = $_[1];
	open(IN, "<$infile") or die "\n\nNADA $infile you FOOL!!!\n\n";
	my @DATA = <IN>; close(IN); shift(@DATA);	
	# 2. Parse sequence data . . . . . . . . . . . . .
	my $unid = $filenumber.100000000001;                           # string to generate unique ids
	foreach my $entry (@DATA)
	{	my @data = split('\n', $entry);
		my $seq = '';
		foreach my $i (1..$#data)
		{	$seq .= $data[$i];  }
		$seq =~ s/>//;
		$BinSeqs{$unid}{'HEAD'}    = $data[0];       # store header
		my @shorthead = split(' ', $data[0]);
		$BinSeqs{$unid}{'SHORT_HEAD'} = $shorthead[0];
		$BinSeqs{$unid}{'gappy-ntseq'}   = uc($seq);       # store aligned sequence
		$BinSeqs{$unid}{'SIZE'}    = length($seq);   # store length
		$seq =~ s/\.//;
                $seq =~ s/\-//;
                $BinSeqs{$unid}{'degapped-ntseq'} = uc($seq);     # store degapped sequence
                $BinSeqs{$unid}{'filenumber'} = $filenumber;
                $unid += 1;
	}
	$/="\n";
}
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
