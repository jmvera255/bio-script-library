#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, $ColNum);
getopts("l:c:", \%opts);

####################################################################
if(@ARGV < 1){
	die "\nInappropriate number of arguments provided!

**********
Usage: compare_list.pl <options> <a single text file or space-delimited list of files> > STDOUT
**********

This script will take a single list and, depending on user parameters, will return all repeating
elements in the list (-l -1) or return all elements and how many times they are found (-l -2)

or

This script will take multiple lists and return all list elements that occur <int> number of
times across the lists where <int> is defined by -l parameter

options:
	-l <int> what is exact number of times the string (aka list element) must occur in 
	         provided list files

	note: when <int> = 0 this script will print out all elements
	of the list, regardless of reoccurence, but it will only 
	print each occurence once 

	note: set limit to -1 to print all repeating elements in file.txt
	note: set limit to -2 to print the element and the number of times
              it appears in the list

	-c <int> use this option to specify which column of strings to use for comparison

	note: use only when provided data is tab-delimited;
	column # starts at 0

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}

elsif( $opts{l} > 1 && @ARGV < 2){
	die "\nInappropriate number of arguments provided!

**********
Usage: compare_list.pl <options> <any # of files> > STDOUT
**********

This script will take a single list and, depending on user parameters, will return all repeating
elements in the list (-l -1) or return all elements and how many times they are found (-l -2)

or

This script will take multiple lists and return all list elements that occur <int> number of
times across the lists where <int> is defined by -l parameter

options:
	-l <int> what is exact number of times the string (aka list element) must occur in 
	         provided list files

	note: when <int> = 0 this script will print out all elements
	of the list, regardless of reoccurence, but it will only 
	print each occurence once 

	note: set limit to -1 to print all repeating elements in file.txt
	note: set limit to -2 to print the element and the number of times
              it appears in the list

	-c <int> use this option to specify which column of strings to use for comparison

	note: use only when provided data is tab-delimited;
	column # starts at 0

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}
######################################################################

my (%count, $col);
my $limit = $opts{l};
if(defined $opts{c}){
	$col = $opts{c};
}

foreach my $file (@ARGV){
	open(FILE, "< $file") || die "Cannot open file $file";
	while(my $line = <FILE>){
		chomp($line);
		if(defined $opts{c}){
			my @tabs = split("\t", $line);
			$count{$tabs[$col]}++;
		}
		else{
			$count{$line}++;
		}
	}
}

foreach my $a (keys %count){
	if($limit == 0){
		print "$a\n";
	}
	elsif($limit == -1 ){
		if($count{$a} > 1){
			print "$a\t$count{$a}\n";
		}
	}
	elsif($limit == -2){
		print "$a\t$count{$a}\n";
	}
	else{
		if($count{$a} == $limit){
			print "$a\n";
			#print "$a\t$count{$a}\n";
		}
	}
}
