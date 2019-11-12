#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::SeqI;

if(@ARGV == 0){
    die "
No FASTA file provided!

*********
Usage: seqstat.pl <any # of fasta files> > STDOUT
*********\n\n";
}

#declare gobal variables    
my($chr, %fa, $seq, $sum, @lens, $len);

#foreach loop to iterate through all .fa files in @ARGV
foreach my $faFile (@ARGV){
	my $seq_in = Bio::SeqIO->new(-file => $faFile, -format => 'fasta'); 
	while(my $seq = $seq_in->next_seq()){
		my $id = $seq -> id;
		$len = $seq->length();
		push(@lens, $len);
		print "$id\t$len\n";
	}
	$sum = 0; 
	$sum += $_ for @lens;
	print "Total length for $faFile = $sum" . "bp\n";
	@lens = ();
}

