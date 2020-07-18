#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("b:l:m:p:q:udZ", \%opts);

my $usage = "********
Usage: TSSDESeq2Bed.pl <options> <DESeq.txt> > STDOUT
********

Where one of the following options must be selected:
	-b <int>   returns TSS with base mean >= int)
	-l <int>   returns TSS with log2 fold change cutoff (shrunken values)
		   default selects all TSS >= and <= int
	-m <int>   log2 fold change cutoff (unshrunken values)
		   default selects all TSS >= and <= int
	-p <int>   p-value max cutoff (p-val < int)
	-q <int>   p-adj (i.e. q-value) max cutoff (p-adj < int)

Additional optional parameters:
	-d	   only return genes with LFC <= int as denoted by -l or -m
	-u	   only return genes with LFC >= int as denoted by -l or -m
	-Z	   print score 0";

if(@ARGV < 1){
	die "\nNo file provided!\n$usage\n";
}

if((not defined $opts{b}) && (not defined $opts{l}) && (not defined $opts{m}) 
	&& (not defined $opts{p}) && (not defined $opts{q})){
	die "User must specify a selection/filter parameter!\n$usage\n";
}

my %strandTest = (
	"plus" => "\+",
	"minus" => "-");

my %colorTest = (
	"plus" => "204,0,0",
	"minus" => "0,0,153");

my @bed = ("LChr", "Position", "Strand");

my $file = shift;
my(@header, %lines);

my $test = 1; ## counter to test for header in first line of input file

open(FILE, "< $file") || die "Cannot open file $file\n";
while (my $line = <FILE>){
	chomp($line);
	if($test == 1){
		@header = split("\t", $line);
	}
	else{
		my @tabs = split("\t", $line);
		for(my $i =0; $i < scalar(@tabs); $i++){
			$lines{$test}{$header[$i]} = $tabs[$i];
		}
	}
	$test++;
}

if(defined $opts{b}){
	my $key = "baseMean";
	foreach my $g (keys %lines){
		if($lines{$g}{$key} < $opts{b}){
			delete $lines{$g};
		}
	}
}

if(defined $opts{l}){
	my $key = "log2FoldChange";
	logFoldCut($key, $opts{l});
}

if(defined $opts{m}){
	my $key = "lfcMLE";
	logFoldCut($key, $opts{m});
}

if(defined $opts{p}){
	my $key = "pvalue";
	ProbCutoff($key, $opts{p});
}

if(defined $opts{q}){
	my $key = "padj";
	ProbCutoff($key, $opts{q});
}

##### print remaining elements in %lines
foreach my $l (keys %lines){
	my @tabs;
	my $k = "lfcMLE";
	my $strand = $strandTest{$lines{$l}{$bed[2]}};
	my $color = $colorTest{$lines{$l}{$bed[2]}};
	my $start = $lines{$l}{$bed[1]} - 1;
	if(defined($opts{Z})){
		push(@tabs, $lines{$l}{$bed[0]}, $start, $lines{$l}{$bed[1]}, "TSS", "0", $strand, $start, $lines{$l}{$bed[1]}, $color);
	}
	else{
		push(@tabs, $lines{$l}{$bed[0]}, $start, $lines{$l}{$bed[1]}, "TSS", $lines{$l}{$k}, $strand, $start, $lines{$l}{$bed[1]}, $color);
	}
	my $newLine = join("\t", @tabs);
	print "$newLine\n";
}

####### subroutines
sub ProbCutoff {
	my $k = $_[0];
	my $int = $_[1];
	my $lineCount = scalar(keys(%lines));
	print STDERR "There are ($lineCount) lines(s) before $k cutoff\n";
	foreach my $g (keys %lines){
		if($lines{$g}{$k} >= $int || $lines{$g}{$k} =~ /NA/){
			delete $lines{$g};
		}
	}
	my $lineCount = scalar(keys(%lines));
	print STDERR "There are ($lineCount) lines(s) after $k cutoff\n";
}
	
sub logFoldCut {
	my $k = $_[0];
	my $int = $_[1];
	if(defined $opts{d}){
		$int = $int * -1;
		print STDERR "The user has requested genes with $k =< $int\n";
		foreach my $g (keys %lines){
			if($lines{$g}{$k} > $int){
				delete $lines{$g};
			}
		}
	}
	elsif(defined $opts{u}){
		print STDERR "The user has requested genes with $k >= $int\n";
		foreach my $g (keys %lines){
			if($lines{$g}{$k} < $int){
				delete $lines{$g};
			}
		}
	}
	else{
		foreach my $g (keys %lines){
			if(($lines{$g}{$k} < $int) && ($lines{$g}{$k} > ($int * -1))){
				delete $lines{$g};
			}
		}
	}
}

			
