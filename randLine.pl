#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("n:h:r", \%opts);


if((@ARGV != 1) || (not defined $opts{n})){
	die "
***********
Usage: randLine.pl <options> <file> > STDOUT
***********

This script will parse any file and return, at random, the # of lines specified
CAUTION: input file lines are stored in temp memory and this script will crap out
if the input file is too large (likely > 20 million lines?)

where options:
	-n <int>    specifies the number of lines to print (required)
	-h <strng>  specifies header character of lines that will not be randomized, 
		    but WILL be printed to STDOUT
	-r	    DO NOT print lines redundantly\n";
}

my $BedFile = shift;
my $LineCount = $opts{n};

my(@lines, %lines);
my $c = 1;

open(FILE, "< $BedFile") || die "cannot open file $BedFile!\n";
while(my $line = <FILE>){
	chomp($line);
	if(defined $opts{h}){
		if($line =~ /^$opts{h}/){
			print "$line\n";
		}
		else{
			if(defined $opts{r}){
				$lines{$c} = $line;
				$c++;
			}
			else{
				push(@lines, $line);
			}
		}
	}
	else{
		if(defined $opts{r}){
			$lines{$c} = $line;
			$c++;
		}
		else{
			push(@lines, $line);
		}
	}
}

if(defined $opts{r}){
	my $a = scalar(keys(%lines));
	for(my $i = 1; $i <= $LineCount; $i++){
		my $z = int(rand($a));
		if(not defined $lines{$z}){
			until(defined $lines{$z}){
				$z = int(rand($a));
			}
		}		
		print "$lines{$z}\n";
		delete $lines{$z};
	}
}
else{
	my $a = scalar(@lines);
	for(my $i = 1; $i <= $LineCount; $i++){
		my $z = int(rand($a));
		print "$lines[$z]\n";
	}
}
