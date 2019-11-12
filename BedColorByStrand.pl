#! /usr/bin/perl

use strict;

if (@ARGV != 1){
	die "\nNo file provided!

********
Usage: BedColorByStrand.pl <file.bed> > STDOUT
********\n";
}

my $bedFile = shift;

open(BED, "< $bedFile") || die "Cannot open file $bedFile\n";
while(my $line = <BED>){
	chomp($line);
	if($line =~ /^#/){
		print "$line\n";
	}
	else{
		my @tabs = split("\t", $line);
		$tabs[6] = $tabs[1];
		$tabs[7] = $tabs[2];
		if($tabs[5] =~ /-/){	
			$tabs[8] = "0,0,153";
		}
		else{
			$tabs[8] = "204,0,0";
		}
		my $newLine = join("\t", @tabs);
		print "$newLine\n";
	}
}
