#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - -
#Goals of script:
#Take the cluster output file from CONCOCT (out_clustering_gt2000.csv) and use to pull bins from the original fasta file.

# - - - - - U S E R    V A R I A B L E S - - - - - - - -


# - - - - - G L O B A L  V A R I A B L E S  - - - - - -
my %options=();
getopts("f:c:o:h", \%options);

if ($options{h})
    {   print "\n\nHelp called:\nOptions:\n";
        print "-f = fasta file with contigs\n";
        print "-c = cluster file from CONCOCT\n";
        print "-o = output prefix\n";
	print "-h = This help message\n\n";
	die;
    }

my %Sequences;

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - M A I N - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
&FASTAread($options{f}, 1);

open(IN2, "<$options{c}") or die "\n\nNADA $options{c} you FOOL!!!\n\n";
my @clust_data = <IN2>; close(IN2);
my @clust_copy = @clust_data;
foreach my $out (@clust_data)
    {   chomp($out);
        my @data = split(',', $out);
        my $outbase = "bin".$data[1];
        open($outbase, ">$options{o}"."_bin_".$data[1].".fasta");        
    }

foreach my $m (@clust_data)
	{	chomp($m);
                my @data = split(',', $m);
                my $outnum = "bin".$data[1];
		if(exists $Sequences{$data[0]})
                	{ print $outnum ">".$Sequences{$data[0]}{'HEAD'}."\n".$Sequences{$data[0]}{'gappy-ntseq'}."\n";
                          #shift(@clust_data);
                        }
	}
	

foreach my $out (@clust_copy)
    {   chomp($out);
        my @data = split(',', $out);
        my $outbase = "bin".$data[1];
        close($outbase);
    }


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
	#my $unid = $filenumber.10001;                           # string to generate unique ids
	foreach my $entry (@DATA)
	{	my @data = split('\n', $entry);
		my $seq = '';
		foreach my $i (1..$#data)
		{	$seq .= $data[$i];  }
		$seq =~ s/>//;
		$Sequences{$data[0]}{'HEAD'}    = $data[0];       # store header
		my @shorthead = split(' ', $data[0]);
		$Sequences{$data[0]}{'SHORT_HEAD'} = $shorthead[0];
		$Sequences{$data[0]}{'gappy-ntseq'}   = uc($seq);       # store aligned sequence
		$Sequences{$data[0]}{'SIZE'}    = length($seq);   # store length
		$seq =~ s/\.//;
                $seq =~ s/\-//;
                $Sequences{$data[0]}{'degapped-ntseq'} = uc($seq);     # store degapped sequence
                $Sequences{$data[0]}{'filenumber'} = $filenumber;
                #$unid += 1;
	}
	$/="\n";
}
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
