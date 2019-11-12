#! /usr/bin/perl
use strict;
use Getopt::Std;
my (%opts);
getopts("c:", \%opts);

if(@ARGV < 1){
	die "
iprintBed.pl <list.txt> <file.bed> > STDOUT

use -c <int> to specify a column is list.txt is tab-delimited\n\n";
}

my(%bedLines);
open(BED, "< $ARGV[1]") || die "Cannot open file.bed $ARGV[1]!\n";
while(my $line = <BED>){
	chomp($line);
	if($line !~/^#/){
		my @tabs = split("\t", $line);
		$bedLines{$tabs[3]} = $line;
	}
}

open(LIST, "< $ARGV[0]") || die "Cannot open $ARGV[0]!\n";
while(my $line = <LIST>){
	chomp($line);
	if(defined($opts{c})){
		my @tabs =  split("\t", $line);
		print "$bedLines{$tabs[$opts{c}]}\n";
	}
	else{
		print "$bedLines{$line}\n";
	}
}
