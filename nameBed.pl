#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, $ColNum);
getopts("n:s:", \%opts);
if (not defined $opts{n}){
	$opts{n} = 1;
}

if(@ARGV != 1){
	die "\nNo file provided!

**********
Usage: nameCUT.pl <option> <file.bed> > STDOUT
**********

-s <str> base name for features (required)
-n <int> designates at what number to start the count at
	 for naming the annotations; default = 1\n";
}

my $file = shift;
my $count = $opts{n};
my $a = $opts{s};

open(FILE, "< $file") || die "Cannot open file $file";
while(my $line = <FILE>){
	chomp($line);
	my @tabs = split("\t", $line);
	my $name = join("", $a, $count);
	$tabs[3] = $name;
	my $newLine = join("\t", @tabs);
	print "$newLine\n";
	$count++;
}
