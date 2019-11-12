#! /usr/bin/perl

use strict;
use List::Util qw( min max );
use List::MoreUtils 'first_index';
use Getopt::Std;

my (%opts);
getopts("S:", \%opts);

if(@ARGV <1){
	die "
You must provided at least one fasta file!

**********
Usage: fasta2ntcountMatrix.pl <options> <file.fa> > STDOUT
**********
where <options>:
	-S	additionally print out a tab delimited file of all
		privided sequences: seq_name<tab>sequence 

Note: the user may provide multiple file.fa\n\n";
}

my (%fa, $name, $seq);
foreach my $file (@ARGV){
	open(FASTA, "< $file") || die "Cannot open fasta $file!\n";
	while(my $line = <FASTA>){
		chomp($line);
		if($line =~ /^>(\S+)/){
			$name = $1;
			$seq = "";
		}
		else{
			$seq = $seq . $line;
			$fa{$name} = $seq;
		}
	}
}
	
if(defined($opts{S})){
	open(TXT, "> $opts{S}") || die "Cannot open secondary output file!\n";
}

my(%count, %bases);
foreach my $s (keys %fa) {
	if(defined($opts{S})){
		print TXT "$s\t$fa{$s}\n";
	}
	my @S = split("", $fa{$s});
	for(my $i = 0; $i < scalar(@S); $i++){
		my $j = $i + 1;
		$count{$j}{$S[$i]}++;
		$bases{$S[$i]}++;
	}
}

##########_print_count_matrix_##########
foreach my $base (sort {$a cmp $b} keys %bases){
	print "$base\t";
	foreach my $p (sort {$a <=> $b} keys %count){
		print "$count{$p}{$base}\t";
	}
	print "\n";
}

my $printMax = "Max";
my $printBase = "Base";
#########_print_max_value_and_base_##########
foreach my $p (sort {$a <=> $b} keys %count){
	my @Counts = ();
	my @B = ();
	foreach my $base (keys %{$count{$p}}){
		push(@B, $base);
		push(@Counts, $count{$p}{$base}); 
	}
	my $max =  max(@Counts);
	my $index = first_index { /$max/ } @Counts;
	my $max_base = $B[$index];
	$printMax = $printMax . "\t$max";
	$printBase = $printBase . "\t$max_base";
}

print "$printMax\n";
print "$printBase\n";

