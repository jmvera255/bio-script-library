#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("P:h:G:m:M:o", \%opts);

if((not defined $opts{P}) || (not defined $opts{h}) || (not defined $opts{G})){
	die "\nUser must specify input

Usage: GeneSetHyperTestOut.pl <options> > STDOUT

Where the following options are required:
	-P <file.txt>	list of genes in population
	-h <file.txt>	list of hits from DE test or cluster
	-G <file.txt>	gene set

optional parameters:
	-o		specify that gene set file is GO (slightly different format)
	-M <int>	max size of gene set
	-m <int>	min size of gene set\n\n";
}

#### parse population list
my(@population);
open(TXT, "< $opts{P}") || die "Script terminated, cannot open $opts{P}!\n";
while(my $line =<TXT>){
	chomp($line);
	push(@population, $line);
}

my $P = scalar(@population);

close(TXT);

#### parse hit list
my(@hits);
open(TXT, "< $opts{h}") || die "Script terminated, cannot open $opts{h}!\n";
while(my $line =<TXT>){
	chomp($line);
	push(@hits, $line);
}

my $k = scalar(@hits);
close(TXT);

#### parse gene sets
my(%preGS, %GSnames, $name);
open(TXT, "< $opts{G}") || die "Script terminated, cannot open $opts{G}!\n";
while(my $line = <TXT>){
	chomp($line);
	my @tabs = split("\t", $line);
	if(defined($opts{o})){
		my @tabs2 = split(":", $tabs[1]);
		$name = "GO" . $tabs2[1];
		$GSnames{$name} = $tabs[2];
	}
	else{
		$name = "K" . $tabs[2];
		$GSnames{$name} = $tabs[3];
	}
	my $dump = shift(@tabs);
	$dump = shift(@tabs);
	$dump = shift(@tabs);
	$dump = shift(@tabs);
	foreach my $t (@tabs){
		$preGS{$name}{$t} = 1;
	}
}
close(TXT);

#### create post processed GS
my(%postGS);
foreach my $GS (keys %preGS){
	foreach my $g (@population){
		if(defined($preGS{$GS}{$g})){
			$postGS{$GS}{$g} = 1;
			#print STDERR "gene ($g) is in gene set ($GS)\n";
		}
	}
}

#### calculate # of success in hit list per post processed gene set
#### print results to stdout
#print "Gene Set\tDescription\tq\tm\tn\tk\n";
print "Gene Set\tDescription\tq\tm\tn\tk\n";

my($q);
foreach my $GS (keys %postGS){
	$q = -1;
	foreach my $g (@hits){
		#print STDERR "The gene set is $GS and the hit is ($g)\n";
		if(defined($postGS{$GS}{$g})){
			$q++;
			#print STDERR "gene $g is in set $GS! and q = $q\n";
		}
	}
	my $m = scalar(keys %{$postGS{$GS}}); ## m = size of gene set
#	print STDERR "$GS\t$m\n";
	my $n = $P - $m;
	if($q >= 1){
	if(defined $opts{M} && $m <= $opts{M}){
		if(defined $opts{m} && $m >= $opts{m}){
			print "$GS\t$GSnames{$GS}\t$q\t$m\t$n\t$k\n";
		}
		elsif(not defined $opts{m}){
			print "$GS\t$GSnames{$GS}\t$q\t$m\t$n\t$k\n";
		}
	}
	if(defined $opts{m} && $m >= $opts{m} && not defined $opts{M}){
		print "$GS\t$GSnames{$GS}\t$q\t$m\t$n\t$k\n";
	}
	if((not defined $opts{M}) && (not defined $opts{m})){
		print "$GS\t$GSnames{$GS}\t$q\t$m\t$n\t$k\n";
	}
	}
}
		
	

