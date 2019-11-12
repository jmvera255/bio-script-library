#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::SeqI;
use Getopt::Std;

my (%opts, $ColNum);
getopts("G", \%opts);


if(@ARGV == 0){
    die "
No FASTA file provided!

*********
Usage: ntcount.pl <options> <any # of fasta files> > STDOUT
*********

where options are:
	-G	Global nucleotide count; i.e. report the total
		# of A,T,G,C across all sequences in fasta

default is to report per sequence in the fasta\n\n";
}

#declare gobal variables    
my($chr, %fa, $seq, @lens, $len, @totalC, @totalG, @totalA, @totalT);

#foreach loop to iterate through all .fa files in @ARGV
foreach my $faFile (@ARGV){
	my $seq_in = Bio::SeqIO->new(-file => $faFile, -format => 'fasta'); 
	while(my $seq = $seq_in->next_seq()){
		my $id = $seq -> id;
		$len = $seq->length();
		my $seqString = $seq -> subseq(1, $len);
		my @G = $seqString =~ /G/g;
		my @C = $seqString =~ /C/g;
		my @A = $seqString =~ /A/g;
		my @T = $seqString =~ /T/g;
		my $GC = ((scalar(@G) + scalar(@C))/$len)*100;
		push(@totalG, scalar(@G));
		push(@totalA, scalar(@A));
		push(@totalC, scalar(@C));
		push(@totalT, scalar(@T));
		if(not defined $opts{G}){
			print "Sequence:$id
A = " . scalar(@A) . "
T = " . scalar(@T) . "
G = " . scalar(@G) . "
C = " . scalar(@C) . "
Total length = $len
Total GC = $GC\n";
		}
	}
}

if(defined $opts{G}){
	my $sum = 0;
	$sum += $_ for @totalG;
	print "G\t$sum\n";
	my $sum = 0;
	$sum += $_ for @totalA;
	print "A\t$sum\n";
	my $sum = 0;
	$sum += $_ for @totalT;
	print "T\t$sum\n";
	my $sum = 0;
	$sum += $_ for @totalC;
	print "C\t$sum\n";
}




