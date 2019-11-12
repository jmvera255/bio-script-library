#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("b:g:m:c", \%opts);

if((not defined $opts{b}) && (not defined $opts{g})){
	die "
*********
Usage: intergenicBed.pl <options> > STDOUT
*********

This script will take in a bed file and returns a bed file pertaining to
intergenic space between features in input file.bed where intergenic space
is named based on the downstream feature name (i.e. intergenic region
will be directly upstream of that gene). 

Options:
	-g <genome.txt>		Specify genome dictionary/seqstat file
	-b <file.bed>		Specify input bed file
	-c			Genome is circular; Two intergenic regions
				will be produced when spanning the \"ends\"\n";
}
#########_Parse Genome File_###########
my(%genome);
open(GENOME, "< $opts{g}") || die "Cannot open genome file $opts{g}!\n";
while(my $line =<GENOME>){
	chomp($line);
	if ($line !~ /^#/){
		my @tabs = split("\t", $line);
		$genome{$tabs[0]} = $tabs[1];
	}
}

#########_Parse Bed File_###########
my(%plus, %minus, %nameTest);
open(BED, "< $opts{b}") || die "Cannot open bed file $opts{b}!\n";
while(my $line =<BED>){
	chomp($line);
	if ($line !~ /^#/){
		my @tabs = split("\t", $line);
		$nameTest{$tabs[3]}++;
		if($tabs[5] =~ /-/){
			#push(@{$minus{$tabs[0]}{$tabs[1]}}, $tabs[2], $tabs[3]);
			push(@{$minus{$tabs[0]}{$tabs[2]}}, $tabs[1], $tabs[3]);
		}
		else{
			push(@{$plus{$tabs[0]}{$tabs[1]}}, $tabs[2], $tabs[3]);
		}
	}
}

#########_Generate Intergenic regions_###########
foreach my $chr (sort {$a cmp $b} keys %plus){
	my($newStart, %IGR, $gName, $first);
	my $c = 1;
	my(@first, $fLen);
	foreach my $newStop (sort {$a <=> $b} keys %{$plus{$chr}}){
		$gName = $plus{$chr}{$newStop}[1];
		if($c == 1){
			$newStart = 0;
			$first = $gName;
			$fLen = $newStop - $newStart;
			push(@first, $chr, $newStart, $newStop, $gName, $fLen, "+");
		}
		else{
			$IGR{$gName} = join("\t", $chr, $newStart, $newStop, $gName, ($newStop - $newStart), "+");
		}
		$newStart = $plus{$chr}{$newStop}[0];
		$c++;
	}
	if(defined $opts{c}){
		my $fullLen = $fLen + ($genome{$chr} - $newStart);
		$IGR{"last"} = join("\t", $chr, $newStart, $genome{$chr}, $first, $fullLen, "+");
		$first[4] = $fullLen;
	}
	$IGR{"first"} = join("\t", @first);
	###Print_results_per_chro
	foreach my $g (keys %IGR){
		print "$IGR{$g}\n";
	}
}

foreach my $chr (sort {$a cmp $b} keys %minus){
	my($newStop, %IGR, $gName, $first);
	my $c = 1;
	my(@first, $fLen);
	foreach my $newStart (sort {$b <=> $a} keys %{$minus{$chr}}){
		$gName = $minus{$chr}{$newStart}[1];
		if($c == 1){
			$newStop = $genome{$chr};
			$first = $gName;
			$fLen = $newStop - $newStart;
			push(@first, $chr, $newStart, $newStop, $gName, $fLen, "-");
		}
		else{
			$IGR{$gName} = join("\t", $chr, $newStart, $newStop, $gName, ($newStop - $newStart), "-");
		}
		$newStop = $minus{$chr}{$newStart}[0];
		$c++;
	}
	if(defined $opts{c}){
		my $fullLen = $fLen + $newStop;
		$IGR{"last"} = join("\t", $chr, 0, $newStop, $first, $fullLen, "-");
		$first[4] = $fullLen;
	}
	$IGR{"first"} = join("\t", @first);
	####Print_results_per_chr
	foreach my $g (keys %IGR){
		print "$IGR{$g}\n";
	}
}
