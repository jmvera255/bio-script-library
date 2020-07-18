#! /usr/bin/perl

use strict;
use Getopt::Std;
use List::Util qw( min max );
use List::MoreUtils 'first_index';

my (%opts);
getopts("m:,p:,b:,g:L:,C:,O:", \%opts);

if((not defined $opts{m}) || (not defined $opts{p}) || 
(not defined $opts{b}) || (not defined $opts{g}) ||
(not defined $opts{L}) || (not defined $opts{C}) ||
(not defined $opts{O})){
	die "User has not provided all required arguments!!

#########
Usage: annotateTSS.pl <options> > STDOUT
#########

options:
	-m		Rpph(-) data
	-p		Rpph(+) data
	-g		Genome.dict/genome.seqstat.txt
	-b		bed file used to generate coverage data
	-L <int>	log2 fold limit >= will only be considered
	-C <int>	coverage cutoff, will only analyze if Rpph(+) cov >= int
	-O <path/out.txt>	path and file name for secondary output
				specifying the TSS and CDS start coords and the
				Rpph(+), Rpph(-), and log2(fold) data per main hit

This script will output a BED file containing the best hit for a 
TSS in proper stranded color and up to an additional 2 hits in grey\n\n";
}

my(%genome, %bed, %test);
my $S = 85;  ##initial IGR length to find TSS before parsing entire length
open(OUT, "> $opts{O}") || die "Cannot open secondary output file $opts{O}!\n\n";
print OUT "#chr\tTSS\tCDS\tfeature\tRpph(+)\tstrand\tRpph(-)\tlog2\n";

#########_parse_genome_dictionary_###############
open(GENOME, "< $opts{g}") || die "cannot open the genome dictionary $opts{g}!\n";
while(my $line = <GENOME>){
	chomp($line);
	my @tabs = split("\t", $line);
	$genome{$tabs[0]} = $tabs[1];
}
close(GENOME);

#########_parse_bed_file_#########################
open(BED, "< $opts{b}") || die "Cannot open bed file $opts{b}!\n";
while(my $line = <BED>){
	chomp($line);
	my @tabs = split("\t", $line);
	if(defined $bed{$tabs[3]}){
		$test{$tabs[3]};
#		for(my $i = 0; $i < scalar(@tabs); $i++){
#			push(@{$bed{$tabs[3]}[$i]}, $tabs[$i]); ##bed{geneName}[0=chr][1=start]...etc
#		}
	}
	else{
		@{$bed{$tabs[3]}} = @tabs;
	}
}
close(BED);

############_parse_cov_data_##############
my(%plus, %minus);
open(FILE, "< $opts{p}") || die "Cannot open $opts{p}!\n";
while(my $line = <FILE>){
	chomp($line);
	my @tabs = split("\t", $line);
	my $gene = shift(@tabs);
	@{$plus{$gene}} = @tabs;
}
close(FILE);

open(FILE, "< $opts{m}") || die "Cannot open $opts{p}!\n";
while(my $line = <FILE>){
	chomp($line);
	my @tabs = split("\t", $line);
	my $gene = shift(@tabs);
	@{$minus{$gene}} = @tabs;
}
close(FILE);

##############_analyze_cov_data_############
my($color, %cHash);
my $count = 0;
foreach my $g (keys %plus){
	my (@TSSposition, @hits, @cov, $c, @cov_minus);
	$count++;
	for(my $i = scalar(@{$plus{$g}}); $i > (scalar(@{$plus{$g}})) - $S; $i--){
		if($plus{$g}[$i] >= $opts{C}){ ## check for coverage cutoff
			my $fold = ($plus{$g}[$i] + 1)/($minus{$g}[$i] + 1);
			my $lg2 = log2($fold);
			$lg2 = sprintf("%.4f",$lg2);
			if($lg2 >= $opts{L}){
				$cHash{$count}++;
				if(not defined $test{$g}){
					if($bed{$g}[5] =~ /-/){
						$c = $bed{$g}[2] - $i - 1;
					}
					else{
						$c = $bed{$g}[1] + $i;
					}
				}
				push(@TSSposition, $c);
				push(@hits, $lg2);
				push(@cov, $plus{$g}[$i]);
				push(@cov_minus, $minus{$g}[$i]);
			}
		}
	}
	if(scalar(@hits) == 0){
		for(my $i = 0; $i < scalar(@{$plus{$g}}); $i++){
			if($plus{$g}[$i] >= $opts{C}){ ##check for coverage cutoff
				my $fold = ($plus{$g}[$i] + 1)/($minus{$g}[$i] + 1);
				my $lg2 = log2($fold);
				$lg2 = sprintf("%.4f",$lg2);
				if($lg2 >= $opts{L}){
					if(not defined $test{$g}){
						if($bed{$g}[5] =~ /-/){
							$c = $bed{$g}[2] - $i - 1;
						}
						else{
							$c = $bed{$g}[1] + $i;
						}
					}
					push(@TSSposition, $c);
					push(@hits, $lg2);
					push(@cov, $plus{$g}[$i]);
					push(@cov_minus, $minus{$g}[$i]);
				}
			}
		}
	}
	if(scalar(@hits) != 0){
		my $max =  max(@cov);
		my $index = first_index { /$max/ } @cov;
		my $s = $TSSposition[$index];
		if($bed{$g}[5] =~ /-/){
			$color = "0,0,153";
		}
		else{
			$color = "204,0,0";
		}
		my $out = join("\t", $bed{$g}[0], $s, ($s + 1), $g, $max, $bed{$g}[5], $s, ($s + 1), $color);
		print "$out\n";
		my (@temp);
		if(not defined $test{$g}){
			if($bed{$g}[5] =~ /-/){
				push(@temp, $bed{$g}[0], $s, ($bed{$g}[1] + 10), $g, $max, 
				$bed{$g}[5], $cov_minus[$index], $hits[$index]);
			}
			else{
				push(@temp, $bed{$g}[0], $s, ($bed{$g}[2] - 10), $g, $max, 
				$bed{$g}[5], $cov_minus[$index], $hits[$index]);
			}
			my $line = join("\t", @temp);
			print OUT "$line\n";
		}
		if(scalar(@hits) >= 3){
			$color = "75,75,75";
			for(my $i = 2; $i < 4; $i++){
				splice(@cov, $index, 1);
				splice(@hits, $index, 1);
				splice(@TSSposition, $index, 1);
				$max =  max(@cov);
				$index = first_index { /$max/ } @cov;
				$s = $TSSposition[$index];
				my $out = join("\t", $bed{$g}[0], $s, ($s + 1), $g, 
				$max, $bed{$g}[5], $s, ($s + 1), $color);
				print "$out\n";
			}
		}
	}
}
close(OUT);
my @temp = keys %cHash;
my $c = scalar(@temp);
print "## $c total genes with a TSS with -75+10bp of annotated stop codon";

##############_subroutines_###############
sub log2 {	
	my $n = shift;	
	return(log($n)/log(2));
}
