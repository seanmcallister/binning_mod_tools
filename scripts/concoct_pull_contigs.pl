#!/usr/bin/perl -w
#use strict;
use Getopt::Std;

# - - - - - H E A D E R - - - - - - - - - - - - - - - - -
#Goals of script:
#Strangely, CONCOCT doesn't pull out bins after binning is completed. This should fix that!
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

foreach my $i (sort keys %Sequences)
	{	foreach my $m (@clust_data)
		{       chomp($m);
                        my @data = split(',', $m);
                        my $outnum = "bin".$data[1];
			if($Sequences{$i}{'SHORT_HEAD'} eq $data[0])
                            { print $outnum ">".$Sequences{$i}{'HEAD'}."\n".$Sequences{$i}{'gappy-ntseq'}."\n";
                              shift(@clust_data);
                            }
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
	my $unid = $filenumber.10001;                           # string to generate unique ids
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
# - - - - - EOF - - - - - - - - - - - - - - - - - - - - - -
