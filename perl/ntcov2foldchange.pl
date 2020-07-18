#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, $ColNum);
getopts("fazpn:", \%opts);

my $usage = "********
Usage: ntcov2foldchange.pl <options> <ntcov.txt 1> <ntcov.txt 2> > STDOUT
********

This script will perform mathematical manipulations on read coverage data in ntcov.txt format
(i.e. bedTools genomeCoverageBed -d). Options include normalizing read coverage (-n), averaging data
across samples (-a), pooling data across  

where options are:
	-f	 foldchange is calculated as file1/file2
	-a	 value at each position is averaged across; >= 2 ntcov.txt files must/can be provided
	-z	 report all nonzero (> 0) coverage positions; user can provide any number of ntcov.txt files
		 but will report positions that are nonzero only in at least one of the files
	-p	 pool (i.e. sum) all values at each position; >= 2 ntcov.txt files must/can be provided
	-n <int> normalize the value at each position by dividing by <int>; 
		 User must only provide a single ntcov.txt file

This script was written by Jessica M. Vera, for questions please contact her.\n\n";

if(defined $opts{n}){
	if(@ARGV != 1){
		die "\nUser must only provide a single ntcov.txt file when using the -n option!\n\n$usage\n";
	}
}

else{
	if(@ARGV < 2){
		die "\nInappropriate number of files provided.\n\n$usage\n";
	}
}

my(%hash, $strand, @cov, $int, $sum, %nonZero);

foreach my $file (@ARGV){
	open(FILE, "< $file") || die "cannot open file $file";
	while(my $line = <FILE>){
		if($line =~ /^#/){
		}
		chomp($line);
		my @tabs = split("\t", $line);
		#$tabs[2] = $tabs[2];
		push(@{$hash{$tabs[0]}{$tabs[1]}}, $tabs[2]);
		#$strand = $tabs[3];
	}
}

foreach my $chr (sort {$a cmp $b} keys %hash){
	foreach my $nt (sort {$a <=> $b} keys %{$hash{$chr}}){
		if(defined $opts{f}){
			my $fold = (1 + $hash{$chr}{$nt}[0])/(1 + $hash{$chr}{$nt}[1]);
			#$newFold = sprintf("%.6f",$fold);
			print "$chr\t$nt\t$fold\n";
			#print "$chr\t$nt\t$fold\t$hash{$chr}{$nt}[0]\t$hash{$chr}{$nt}[1]\n";
		}
		elsif(defined $opts{a}){
			my $ave = ($hash{$chr}{$nt}[0] + $hash{$chr}{$nt}[1])/2;
			#$newFold = sprintf("%.6f",$fold);
			print "$chr\t$nt\t$ave\n";
		}
		elsif(defined $opts{p}){
			$sum = 0; 
			$sum += $_ for @{$hash{$chr}{$nt}};
			#$newFold = sprintf("%.6f",$fold);
			print "$chr\t$nt\t$sum\n";
		}
		elsif(defined $opts{z}){
			foreach my $test (@{$hash{$nt}}){
				if($test > 0){
					push(@{$nonZero{$chr}{$nt}}, $test);
				}
			}
#			if($hash{$chr}{$nt}[0] > 0){
#				#print "$chr\t$nt\t$hash{$chr}{$nt}[0]\n";
#				push(@cov, $hash{$chr}{$nt}[0]);
#			}
#			if($hash{$chr}{$nt}[1] > 0){
#				#print "$chr\t$nt\t$hash{$chr}{$nt}[0]\n";
#				push(@cov, $hash{$chr}{$nt}[1]);
#			}
		}
		elsif(defined $opts{n}){
			my $int = $opts{n};
			my $z = $hash{$chr}{$nt}[0];
			if($z != 0){
				$z = $z/$int;
				$z = sprintf("%.6f",$z);
			}
			print "$chr\t$nt\t$z\n";
		}

	}
}

if(defined $opts{z}){
	foreach my $chr (sort {$a cmp $b} keys %nonZero){
		foreach my $nt (sort {$a <=> $b} keys %{$nonZero{$chr}}){
			print "$chr\t$nt\t";
			my $line = join(@{$nonZero{$chr}{$nt}});
			print "$line\n";
		}
	}
#	@cov = sort {$a <=> $b} @cov;
#	foreach my $c (@cov){
#		print "$c\n";
}
