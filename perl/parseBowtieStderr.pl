#! /usr/bin/perl
use strict;
use Getopt::Std;
my (%opts, @samples);
getopts("S:c:", \%opts);


if(@ARGV < 1){
	die "No file provided!

***********
Usage: parseBowtieStderr.pl <options> <any # of file.stderr> > STDOUT
***********

You can provide as many stderr files as you want

options:
	-S	provide a list of sample names, must be in same order as
		set of stderr files provided, if this file is tab delimited
		then you must use -c option

	-c	specify which column of data to use from file -S

Note: This script is currently only compatible with Bowtie v1 stderr\n\n";
}

if(defined $opts{S}){
	open(SAMPLES, "< $opts{S}") || die "cannot open samples list $opts{S}!\n";
	while (my $line =<SAMPLES>){
		chomp($line);
		if($line !~ /^#/){
			if(defined $opts{c}){
				my @tabs = split("\t", $line);
				push(@samples, $tabs[$opts{c}]);
			}
			else{
				push(@samples, $line);
			}
		}
	}
}
		

print "#Sample\tTotal Reads\tReads Mapped\n";
my $count = 0;
foreach my $file (@ARGV){
	open(FILE, "< $file") || die "cannot open file $file!\n";
	if(defined $opts{S}){
		print "$samples[$count]\t"
	}
	else{
		print "$file\t";
	}
	while(my $line =<FILE>){
		chomp($line);
		if($line =~ /^# reads processed: (\d+)$/){
			print "$1\t";
		}
		elsif($line =~ /# reads with at least one reported alignment: (\d+)/){
			print "$1\n";
		}
	}
	$count++;
}

