#! /usr/bin/perl

use strict;

if (@ARGV != 3){
	die "Inappropriate number of arguments provided!

*********
Usage: parseClosestBed.pl <file.closestBed> <lower> <upper> > STDOUT
*********

This script will parse the output of closestBed using -d or -D option
where the distance between the two features is listed.  This script
assumes that distance is in the 13th column (i.e. both bed files
contained 6 columns).  <lower> and <upper> refer to distance range for
values in 13th column where <lower> <= distance < <upper>\n\n";
}

my $file = shift;
my $l = shift;
my $u = shift;

open(FILE, "< $file") || die "Cannot open $file!\n";
while(my $line =<FILE>){
	chomp($line);
	my @tabs = split("\t", $line);
	#if($tabs[12] >= $l && $tabs[12] < $u){
	if($tabs[12] >= $l){
		print "$line\n";
	}
}
