#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use Bio::Seq;
use Bio::SeqI;
use Bio::Tools::CodonTable;
use Getopt::Std;
my (%opts, $chr, %fa, $seq);
getopts("f:t:NTC", \%opts);

#if(not defined $opts{C} && @ARGV == 0){
if(@ARGV == 0 && not defined($opts{C})){
    die "
No FASTA file provided!

*********
Usage: seqstat.pl <options> <any # of fasta files> > STDOUT
*********

This script will take an RNA fasta file and translate each RNA sequence
into single letter amino acid sequences. Default output format is fasta.

where options are:
	-t <int>  specifies which codon translation table to use
		  default is 1 (i.e. the standard)
		  For more info on genetic code options see
		  https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi
		  The BioPerl module in this script will not recognize all 33 genetic codes

	-f <int>  specifies which frame to use for translation, options are 0,1,2
		  default is 0 (i.e. the first frame)

	-N	  don't print the * stop symbol

	-T	  return translation in tab-delimited format

	-C	  print all genetic code table options

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}
elsif(defined $opts{C}){
	for(my $i=1;$i<=25;$i++){
		my $codon = Bio::Tools::CodonTable ->new(-id => $i);
		my $tableName = $codon -> name();
		print STDERR "\n$i = $tableName\n";
	}
}

#declare gobal variables
my($chr, %fa, $seq, $sum, @lens, $len);
my $frame = 0;
my $table = 1;

if(defined $opts{f}){
	print STDERR "\nThe user has requested to translate frame $opts{f}\n";
	$frame = $opts{f};
}
if(defined $opts{t}){
	$table = $opts{t};
	my $codon = Bio::Tools::CodonTable ->new(-id => $opts{t});
	my $tableName = $codon -> name();
	print STDERR "\nThe user has requested to use condon table #$table $tableName\n";
}
else{
	print STDERR "\nThe user is using the standard codon table\n";
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

		if(defined $opts{T}){
			my $seq_out= Bio::SeqIO->new(-format => 'tab');
			$seq_out ->write_seq($protein);
		}
		else{
			my $seq_out = Bio::SeqIO->new(-format => 'fasta');
			$seq_out ->write_seq($protein);
		}
	}
}
