#! /usr/bin/perl

use strict;
use Storable;


if (@ARGV != 1){
	die "\nPlease provide a FASTA file

*********
Usage: SeqReverseCompliment.pl <file.fa> > STDOUT
*********\n";
}

my $FAfile = shift;
my($seq, %fa, $seqName);

open(FA, "< $FAfile") || die "Cannot open file $FAfile!";
while(my $line = <FA>){
	chomp($line);
	if($line =~ /^>(\S+)/){
		$seqName = $1;
		$seq = "";
	}
	else{
		$seq = $seq . $line;
		$fa{$seqName} = $seq;
	}
}

foreach my $s (keys %fa){
	my $temp = $fa{$s};
	$temp =~ tr/ATCGN/TAGCN/;
	my @temp = split("", $temp);
	print ">$s\n";
	$temp = join("", reverse @temp);
	print "$temp\n";
	#$genome{$ARGV[0]}{$s} = $temp;
}
