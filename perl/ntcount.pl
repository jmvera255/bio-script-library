#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::SeqI;
use Getopt::Std;

my (%opts, $ColNum);
getopts("GR", \%opts);


if(@ARGV == 0){
    die "
No FASTA file provided!

*********
Usage: ntcount.pl <options> <any # of fasta files, space delimited> > STDOUT
*********

Given a fasta file of DNA (default) sequences this script will report back the 
GCAT nucleotide count per sequence (default).

where options are:
	-G	Global nucleotide count; i.e. report the total
		# of A,T,G,C across all sequences in fasta

	-R	sequence is RNA instead of DNA (default)

default is to report per sequence in the fasta

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}

if(defined($opts{R})){
	print "Sequence\tA\tU\tG\tC\tLength\t%GC\n"
}
else{
	print "Sequence\tA\tT\tG\tC\tLength\t%GC\n"
}

#declare gobal variables    
my($chr, %fa, $seq, @lens, $len, @totalC, @totalG, @totalA, @totalT, @totalU);

#foreach loop to iterate through all .fa files in @ARGV
foreach my $faFile (@ARGV){
	my(@T, @U);
	my $seq_in = Bio::SeqIO->new(-file => $faFile, -format => 'fasta'); 
	while(my $seq = $seq_in->next_seq()){
		my $id = $seq -> id;
		$len = $seq->length();
		my $seqString = $seq -> subseq(1, $len);
		my @G = $seqString =~ /G/g;
		my @C = $seqString =~ /C/g;
		my @A = $seqString =~ /A/g;
		if(defined($opts{R})){
			@U = $seqString =~ /U/g;
		}
		else{
			@T = $seqString =~ /T/g;
		}
		my $GC = ((scalar(@G) + scalar(@C))/$len)*100;
		push(@totalG, scalar(@G));
		push(@totalA, scalar(@A));
		push(@totalC, scalar(@C));
		push(@lens, $len);
		if(defined($opts{R})){
			push(@totalU, scalar(@U));
		}
		else{
			push(@totalT, scalar(@T));
		}
		if(not defined $opts{G}){
			if(defined($opts{R})){
				my $outLine = join("\t", $id, scalar(@A), scalar(@U), scalar(@G), scalar(@C), $len, $GC);
				print "$outLine\n";
			}
			else{
				my $outLine = join("\t", $id, scalar(@A), scalar(@T), scalar(@G), scalar(@C), $len, $GC);
				print "$outLine\n";
			}
		}
	}
}

if(defined $opts{G}){
	print "Global\t";
	my $sum = 0;
	$sum += $_ for @totalA;
	print "$sum\t";
	
	my $sum = 0;
	if(defined($opts{R})){
		$sum += $_ for @totalU;
		print "$sum\t";
	}
	else{
		$sum += $_ for @totalT;
		print "$sum\t";
	}
	
	my $G = 0;
	$G += $_ for @totalG;
	print "$G\t";
	
	my $C = 0;
	$C += $_ for @totalC;
	print "$C\t";

	my $sum = 0;
	$sum += $_ for @lens;
	print "$sum\t";

	my $GC = ($G + $C)*100/$sum;
	print "$GC\n";
}




