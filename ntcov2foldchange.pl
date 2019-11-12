#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, $ColNum);
getopts("fazpn:", \%opts);

if(defined $opts{n}){
	if(@ARGV != 1){
		die "\nYou must only provided a single ntcov.txt file

********
Usage: ntcov2foldchange.pl -n <int> <file.ntcov.txt> > STDOUT
********\n";
}}

else{
	if(@ARGV < 2){
		die "Inappropriate number of files provided.

********
Usage: ntcov2foldchange.pl <option> <file.ntcov.txt> > STDOUT
********

where options are:
-f	
	foldchange is calculated as file1/file2; includes a  La Place constant of 1
-a	
	value at each position is averaged
-z	
	report all nonzero coverage positions
-p
	pool all values at each position
-n <int>
	normalize the value at each position by <int>\n";
	}
}


my(%hash, $strand, @cov, $int, $sum);

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
			if($hash{$chr}{$nt}[0] > 0){
				#print "$chr\t$nt\t$hash{$chr}{$nt}[0]\n";
				push(@cov, $hash{$chr}{$nt}[0]);
			}
			if($hash{$chr}{$nt}[1] > 0){
				#print "$chr\t$nt\t$hash{$chr}{$nt}[0]\n";
				push(@cov, $hash{$chr}{$nt}[1]);
			}
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
	@cov = sort {$a <=> $b} @cov;
	foreach my $c (@cov){
		print "$c\n";
	}
}
