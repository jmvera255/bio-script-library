#! /usr/bin/perl
use strict;
use Getopt::Std;
my (%opts);
getopts("c:", \%opts);

if(@ARGV < 1){
	die "
printBed.pl <options> <list.txt> <file.bed> > STDOUT

use -c <int> to specify a column in the list.txt if there are multiple columns, also
if multiple columns are present in list.txt it must be tab-delimited

This script will take a list of bed file feature names and return the features in the provided
bed file that have that name. Good for pulling out a subset of features from a larger bed file.

Note: The provided bed file must have at least 4 columns where the 4th column is used to denote
the feature name. 

This script was written by Jessica M. Vera, for questions please contact her.\n\n";

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
