#! /usr/bin/perl

use strict;

my(%hist);
my $seqCount = 0;

if(@ARGV < 1){
	die "No file provided. User must provide at least one fasta file!\n";
}

foreach my $file (@ARGV){
	open(FILE, "< $file") || die "Cannot open $file!\n\n";
	while(my $line =<FILE>){
		chomp($line);
		if($line =~ /^>/){
			### do nothing
		}
		else{
			$seqCount++;
			my @nt = split("", $line);
			for(my $i=0; $i < scalar(@nt); $i++){
				$hist{$i}{$nt[$i]}++
			}
		}
	}
}

my @nt = ("A", "U", "G", "C");

foreach my $N (@nt){
	print "$N";
	foreach my $pos (sort {$a <=> $b} keys %hist){
		if(defined($hist{$pos}{$N})){
			print "\t$hist{$pos}{$N}";
		}
		else{
			print "\t0";
		}
	}
	print "\n";
}
