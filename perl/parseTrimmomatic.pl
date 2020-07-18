#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("P", \%opts);


if(@ARGV < 1){
	die "No input files provided!\n
********
Usage: parseTrimmomatic.pl <options> <any number of trimmomatic STDERR results> > STDOUT
********

where options are:
	-P	specifies that the fastq file is paired end\n\n";
}

my $c = 0;
my($f);

### print header to STDOUT
if(defined $opts{P}){
	print "#File\tTotal_Reads\tPaired\t%_Paired\tR1_total\t%_R1\tR2_total\t%_R2\n";
}
else{
	print "#File\tTotal_Reads\tTrimmed\t%Trimmed\n";
}

### parse trimmomatic.err
foreach my $file (@ARGV){
	open(FILE, "< $file") || die "Cannot open file $file!\n\n";
	if($file =~ /\/(\S+)$/){
		$f = $1;
	}
	else{
		$f = $file;
	}
	my $test = 0;
	while(my $line = <FILE>){
		chomp($line);
		if($line =~ /^Input Read/){
			$test = 1;
			my(@counts);
			my @tabs = split(" ", $line);
			my $c = 0;
			if(defined $opts{P}){
				push(@counts, $f, $tabs[3], $tabs[6], (100 * $tabs[6]/$tabs[3]), 
				($tabs[11] + $tabs[6]), (100 * ($tabs[6] + $tabs[11])/$tabs[3]),
				($tabs[16] + $tabs[6]), (100 * ($tabs[6] + $tabs[16])/$tabs[3]));
			}
			else{
				push(@counts, $f, $tabs[2], $tabs[4], (100 * $tabs[4]/$tabs[2]));
			}
			my $out = join("\t", @counts);
			print "$out\n";
		}
	}
	if($test == 0){
		print STDERR "No results found for file $file\n";
	}
}

