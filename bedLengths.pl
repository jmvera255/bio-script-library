#! /usr/bin/perl

use strict;

if (@ARGV != 1){
	die "No file provided!

**********
Usage: bedLengths.pl <file.bed> > STDOUT
**********

This script will take a bed file and print out the length of each
annotation in the bed file in the following tab-delimited format:

Length	FeatureName
Length	FeatureName
Length	FeatureName
...

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}

my $file = shift;
my(%l);

open(BED, "< $file") || die "Cannot open file $file!";
while(my $line = <BED>){
	if($line =~ /^#/){
	}
	else{
		chomp($line);
		my @tabs = split("\t", $line);
		my $length = ($tabs[2] - $tabs[1]);
		$l{$tabs[3]} = $length;
		#print "$length\t$tabs[3]\n";
		print "$length\t$tabs[3]\n";
	}
}
