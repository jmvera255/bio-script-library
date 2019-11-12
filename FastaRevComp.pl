#! /usr/bin/perl

use strict;

use Getopt::Std;
my (%opts);
getopts("tR", \%opts);


if(@ARGV != 1){
	die "No file provided!

*********
Usage: FastaRevComp.pl <options> <file.fa> > STDOUT
*********

where options are:
	-t    input is tab delimited instead of fasta
	-R    output is RNA instead of default DNA\n\n";
}

my $file = shift;
open(FA, "< $file") || die "Cannot open $file!\n";

while(my $line =<FA>){
	chomp($line);
	if(defined($opts{t})){
		my @tabs = split("\t", $line);
		print "$tabs[0]\t";
		if(defined($opts{R})){
			$tabs[1] =~ tr/ATGC/UACG/;
			print scalar reverse "\n$tabs[1]";
		}
		else{
			$tabs[1] =~ tr/ATGC/TACG/;
			print scalar reverse "\n$tabs[1]";
		}
	}
	else{
		if($line =~ /^>/){
			print "$line\n";
		}
		else{
			if(defined($opts{R})){
				$line =~ tr/ATGC/UACG/;
				print scalar reverse "\n$line";
			}
			else{
				$line =~ tr/ATGC/TACG/;
				print scalar reverse "\n$line";
			}
		}
	}
}
