#! /usr/bin/perl

use strict;

if(@ARGV != 1){
	die "
Incorrect number of argument provided.
********
Usage: gtf2bed.pl <file.gtf>
********
This script will take in a gtf and output a bed 
file called file.bed";
}

my $gtf = shift;
$gtf =~ /^(\S+)\.\S+$/;
my $out_bed = $1 . ".bed";
print "$out_bed\n";

my (@tabs1, $new_line, $score, $feature, $name2, $start, $new_start, $stop, $new_stop, $strand, @tabs2, $z);
open (BED, "> $out_bed");
open (GTF, "< $gtf");
while (my $line1 = <GTF>){
	chomp($line1);
	if($line1 =~ /^#/){
	}
	else{
		@tabs1 = split("\t", $line1);
		$start = $tabs1[3] -1 ;
		$stop = $tabs1[4];
		$strand = $tabs1[6];
#		if($tabs1[8] =~ /gene_id=(\S+); /){
#		if($tabs1[8] =~ /ID=(\S+);/){
		if($tabs1[8] =~ /Parent=(\S+);/){
			$name2= $1;
		
		}
		#if($tabs1[8] =~ /Name=(\S+);/){
		#	$name2 = join("_", $name2, $1);#		}
		#}
		$new_line = "$tabs1[0]\t$start\t$stop\t$name2\t0\t$strand";
		print BED "$new_line\n";
	}
}
