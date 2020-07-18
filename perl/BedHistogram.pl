#! /usr/bin/perl

use strict;
use Storable;
use Getopt::Std;

my (%opts, $ColNum);
getopts("b:Snl:", \%opts);

if(@ARGV < 1){
	die "
********
Usage: BedHistogram.pl <options> <any number of bed files> > STDOUT
*******

The bed files must be on a shared/universal coordinate system

options:

-b<file.bed>	only print out histogram data for regions specified in file.bed

-n		print out in ntcov.txt format
		automatically sums across both strands as in -S option

-S		print out unstranded histogram data; default is stranded

-l		<list.txt> will generate output for each line in list.txt
		by first parsing the bed file providied with list.txt
		Note: only to be used with a single hist bed file\n";
}

my(%histogram, @list);
#my $len = shift;
my %count = %{retrieve('/projects/dowellLab/Vera/Perl_scripts/4xpecanCount.hash')};
my $minus = "-";
my $plus = "+";

if(defined $opts{l}){
	open(LIST, "< $opts{l}") || die "cannot open list $opts{l}";
	while(my $line = <LIST>){
		chomp($line);
		if($line =~ /^#/){
		}
		else{
			push(@list, $line);
		}
	}
	foreach my $l (@list){
		system "grep -w $l $ARGV[0] > .temp.meta.bed";
		open(BED, "< .temp.meta.bed") || die "Cannot open bed file .temp.meta.bed!";
		while(my $line = <BED>){
			chomp($line);
			my @tabs = split("\t", $line);
			for(my $i = $tabs[1] + 1; $i < $tabs[2]; $i++){
				$histogram{$tabs[0]}{$tabs[5]}{$i}++;
			}
		}
		if(defined $opts{n}){
			open(OUT, "> temp.$l.bedhistogram.ntcov.txt");
			foreach my $chr (sort {$a cmp $b} keys %count){
				foreach my $nt (sort {$a <=> $b} keys %{$count{$chr}}){
					print OUT "$chr\t$nt\t";
					if(defined $histogram{$chr}{$plus}{$nt} && defined $histogram{$chr}{$minus}{$nt}){
						my $sum = $histogram{$chr}{$plus}{$nt} + $histogram{$chr}{$minus}{$nt};
						print OUT "$sum\n";
					}
					elsif(defined $histogram{$chr}{$plus}{$nt}){
						print OUT "$histogram{$chr}{$plus}{$nt}\n";
					}
					elsif(defined $histogram{$chr}{$minus}{$nt}){
						print OUT "$histogram{$chr}{$minus}{$nt}\n";
					}
					elsif(not defined $histogram{$chr}{$plus}{$nt} && not defined $histogram{$chr}{$minus}{$nt}){
						print OUT "0\n";
					}
				}
			}
		}
		else{
			open(OUT, "> temp.$l.bedhistogram.txt");
			foreach my $chr (sort {$a cmp $b} keys %count){
				foreach my $nt (sort {$a <=> $b} keys %{$count{$chr}}){
					print OUT "$chr\t$nt\t$count{$chr}{$nt}\t";
					if($histogram{$chr}{$plus}{$nt}){
						print OUT "$histogram{$chr}{$plus}{$nt}\t";
					}
					else{
						print OUT "0\t";
					}
					if($histogram{$chr}{$minus}{$nt}){
						$histogram{$chr}{$minus}{$nt} = $histogram{$chr}{$minus}{$nt} * -1;
						print OUT "$histogram{$chr}{$minus}{$nt}\n";
					}
					else{
						print OUT "0\n";
					}
				}
			}
		}
	}
}

else{
foreach my $bedFile (@ARGV){
	open(BED, "< $bedFile") || die "Cannot open bed file $bedFile!";
	while(my $line = <BED>){
		chomp($line);
		my @tabs = split("\t", $line);
		for(my $i = $tabs[1] + 1; $i < $tabs[2]; $i++){
			$histogram{$tabs[0]}{$tabs[5]}{$i}++;
		}
	}
}

if(defined $opts{n}){
foreach my $chr (sort {$a cmp $b} keys %count){
	foreach my $nt (sort {$a <=> $b} keys %{$count{$chr}}){
		print "$chr\t$nt\t";
		if(defined $histogram{$chr}{$plus}{$nt} && defined $histogram{$chr}{$minus}{$nt}){
			my $sum = $histogram{$chr}{$plus}{$nt} + $histogram{$chr}{$minus}{$nt};
			print "$sum\n";
		}
		elsif(defined $histogram{$chr}{$plus}{$nt}){
			print "$histogram{$chr}{$plus}{$nt}\n";
		}
		elsif(defined $histogram{$chr}{$minus}{$nt}){
			print "$histogram{$chr}{$minus}{$nt}\n";
		}
		elsif(not defined $histogram{$chr}{$plus}{$nt} && not defined $histogram{$chr}{$minus}{$nt}){
			print "0\n";
		}
	}
}}
else{
	foreach my $chr (sort {$a cmp $b} keys %count){
		foreach my $nt (sort {$a <=> $b} keys %{$count{$chr}}){
			print "$chr\t$nt\t$count{$chr}{$nt}\t";
			if($histogram{$chr}{$plus}{$nt}){
				print "$histogram{$chr}{$plus}{$nt}\t";
			}
			else{
				print "0\t";
			}
			if($histogram{$chr}{$minus}{$nt}){
				$histogram{$chr}{$minus}{$nt} = $histogram{$chr}{$minus}{$nt} * -1;
				print "$histogram{$chr}{$minus}{$nt}\n";
			}
			else{
				print "0\n";
			}
		}
	}
}
}
=cut
if(defined $opts{d}){
	open(FILE, "< $opts{d}") || die "cannot open guide bed file $opts{d}";
	while(my $line = <FILE>){
		chomp($line);
		if($line =~ /^#/){
		}
		else{
			my @tabs = split("\t", $line);
			for(my $i = $tabs[1]; $i<= $tabs[2]; $i++){
				print "$tabs[0]\t$i\t$count{$tabs[0]}{$i}\t";
				print "$histogram{$tabs[0]}{$plus}{$i}\t";
				print "$histogram{$tabs[0]}{$minus}{$i}\n";
			}
		}
	}
}
