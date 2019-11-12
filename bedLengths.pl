#! /usr/bin/perl

use strict;

if (@ARGV != 1){
	die "No file provided!

**********
Usage: bedLengths.pl <file.bed> > STDOUT
**********\n";
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

#foreach my $z (sort {$l{$a} <=> $l{$b}} keys %l){
#	print "$l{$z}\t$z\n";
#}
