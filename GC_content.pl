#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::SeqI;
use Getopt::Long;

#declare gobal variables    
my($chr, %fa, $seq, $sum, @lens, $len, $w, $o);

GetOptions('w=i' => \$w, 'o=i' => \$o);
if(
($w !~ /\d+/) ||
($o !~ /\d+/)){
	&usage;
}

if(@ARGV ==0){
    die "
No FASTA file provided!

********
Usage: GC_content.pl <options> <any # file.fa> > STDOUT
********

The following parameters must be specified:
	-w	window size/width
	-o	window overlap\n";
}

#foreach loop to iterate through all .fa files in @ARGV
foreach my $faFile (@ARGV){
	my $seq_in = Bio::SeqIO->new(-file => $faFile, -format => 'fasta'); 
	while(my $seq = $seq_in->next_seq()){
		my $id = $seq -> id;
		$len = $seq->length();
		print "#$id\n";
		for(my $i = 1; $i <= $len; $i = $i + ($w - $o)){
			my $z = $i + $w - 1;
			#print "z = $z\n";
			if($z > $len){
				my $seqString = $seq -> subseq($i, $len);
				#print "$seqString\n";
				my @G = $seqString =~ /G/g;
				my @C = $seqString =~ /C/g;
				my $GC = sprintf("%.2f",(((scalar(@G) + scalar(@C))/($len - $i + 1))*100));
				#print "Hit the end of sequence at i = $i\n";
				my $t = $len - $i + 1;
				#print "Window length is $t\n";
				print "$i\t$GC\n";
			}
			else{
				my $seqString = $seq -> subseq($i, $z);
				#print "$seqString\n";
				my @G = $seqString =~ /G/g;
				my @C = $seqString =~ /C/g;
				my $GC = sprintf("%.2f",(((scalar(@G) + scalar(@C))/$w)*100));
				print "$i\t$GC\n";
			}
		}
	}
}

###########################
#usage statement subroutine
###########################

sub usage{

die"

No windowing parameters provided! 

********
Usage: GC_content.pl <options> <any # file.fa> > STDOUT
********

The following parameters must be specified:
	-w	window size/width
	-o	window overlap\n";
}
