#! /usr/bin/perl

use strict;
use Getopt::Std;
use List::Util qw( min max );
use List::MoreUtils 'first_index';

my (%opts);
getopts("m:,p:,b:,g:L:,C:", \%opts);

if((not defined $opts{m}) || (not defined $opts{p}) ||
(not defined $opts{L}) || (not defined $opts{C})){
	die "User has not provided all required arguments!!

#########
Usage: annotateTSS.pl <options> > STDOUT
#########

options:
	-m		normalized AND complete Rpph(-) ntocv.txt
	-p		normalized AND complete Rpph(+) ntcov.txt
	-b		bed file of regions to scan for TSS (optional)
	-L <int>	log2 fold limit >= will only be considered
	-C <int>	normalized coverage cutoff, will only analyze if Rpph(+) cov >= int

Note:	for simplified command line input the ntcov files should contain both the plus and minus
	strand data in a single file with tab-delimited columns arranged: chr nt + -

This script will output a BED file containing all possible TSS hits\n\n";
}

print "#log2 fold >= $opts{L} with minimum, normalized coverage >= $opts{C}\n";

my(%plus, %minus);
my @strand = ("+", "-");
########_parse ntcov.txt data_#########
open(NTCOV, "< $opts{p}") || die "Cannot open $opts{p}!!\n";
while(my $line = <NTCOV>){
	chomp($line);
	my @tabs = split("\t", $line);
	$plus{$tabs[0]}{$tabs[1]}{$strand[0]} = $tabs[2];
	$plus{$tabs[0]}{$tabs[1]}{$strand[1]} = $tabs[3];
}
close(NTCOV);

open(NTCOV, "< $opts{m}") || die "Cannot open $opts{m}!!\n";
while(my $line = <NTCOV>){
	chomp($line);
	if($line !~ /^#/){
		my @tabs = split("\t", $line);
		$minus{$tabs[0]}{$tabs[1]}{$strand[0]} = $tabs[2];
		$minus{$tabs[0]}{$tabs[1]}{$strand[1]} = $tabs[3];
	}
}

###########_annotate all suitable TSS_###########
if(defined $opts{b}){
	my $c = 1;
	open(BED, "< $opts{b}") || die "Cannot open $opts{b}!!\n";
	while(my $line =<BED>){
		chomp($line);
		if($line !~ /^#/){
			my @tabs = split("\t", $line);
			for(my $i=$tabs[1] + 1; $i <= $tabs[2]; $i++){
				my $p = $plus{$tabs[0]}{$i}{$tabs[5]};
				my $m = $minus{$tabs[0]}{$i}{$tabs[5]};
				my $fold = ($p + 1)/($m + 1);
				my $lg2 = log2($fold);
				if($p >= $opts{C} && $lg2 >= $opts{L}){
					my $start = $i - 1;
					my $color = colorByStrand($tabs[5]);
					my $newLine = join("\t", $tabs[0], $start, $i, "TSS_$c", $p, $tabs[5], $start, $i, $color);
					print "$newLine\n";
					$c++;
				}
			}
		}
	}
}
else{
	my $c = 1;
	foreach my $chr (sort {$a cmp $b} keys %plus){
		foreach my $pos (sort {$a <=> $b} keys %{$plus{$chr}}){
			foreach my $s (@strand){
				my $p = $plus{$chr}{$pos}{$s};
				my $m = $minus{$chr}{$pos}{$s};
				my $fold = ($p + 1)/($m + 1);
				my $lg2 = log2($fold);
				if($p >= $opts{C} && $lg2 >= $opts{L}){
					my $start = $pos - 1;
					my $color = colorByStrand($s);
					my $newLine = join("\t", $chr, $start, $pos, "TSS_$c", $p, $s, $start, $pos, $color);
					print "$newLine\n";
					$c++;
				}
			}
		}
	}
}

##############_subroutines_###############
sub log2 {	
	my $n = shift;	
	return(log($n)/log(2));
}

sub colorByStrand {
	if($_[0] =~ /-/){
		return "0,0,153";
	}
	else{
		return "204,0,0";
	}
}
