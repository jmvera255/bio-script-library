#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::Seq;
use Bio::SeqI;
use Bio::Tools::CodonTable;
use Getopt::Std;
my (%opts, $chr, %fa, $seq);
getopts("f:T:Nt", \%opts);

if(@ARGV == 0){
    die "
No FASTA file provided!

*********
Usage: seqstat.pl <options> <any # of fasta files> > STDOUT
*********

where options are:
	-T <int>  specifies which codon translation table to use
		  default is 1 (i.e. the standard)
	-f <int>  specifies which frame to use for translation, options are 0,1,2
		  default is 0 (i.e. the first frame)
	-N	  don't print the * stop symbol
	-t	  print in tab-delimited format instead of fasta (default)\n\n";
}

#declare gobal variables    
my($chr, %fa, $seq, $sum, @lens, $len);
my $frame = 0;
my $table = 1;

if(defined $opts{f}){
	print STDERR "\nThe user has requested to translate frame $opts{f}\n";
	$frame = $opts{f};
}
if(defined $opts{T}){
	$table = $opts{T};
	my $codon = Bio::Tools::CodonTable ->new(-id => $opts{T});
	my $tableName = $codon -> name();
	print STDERR "\nThe user has requested to use condon table #$table $tableName\n";
}

foreach my $faFile (@ARGV){
	my $seq_in = Bio::SeqIO->new(-file => $faFile, -format => 'fasta'); 
	while(my $seq = $seq_in->next_seq()){
		my($protein);
		my $id = $seq -> id;
		$protein = $seq -> translate(-frame => $frame, -condontable_id => $table);
		if(defined $opts{N}){
			my $len = $protein -> length;
			$len = $len - 1;
			$protein = $protein -> trunc(1,$len);
		}

		if(defined($opts{t})){
			my $seq_out = Bio::SeqIO->new(-format => 'tab');
			$seq_out ->write_seq($protein);
		}
		else{
			my $seq_out = Bio::SeqIO->new(-format => 'fasta');
			$seq_out ->write_seq($protein);
		}
	}
}

