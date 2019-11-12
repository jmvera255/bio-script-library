#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("rCS:", \%opts);

if(@ARGV < 1){
	die "
No file provided!

********
Usage: gff2bed.pl <options> <file.gff3> > STDOUT
********

options:
	-r	reverse conversion, i.e. bed2gff
	-C	Bed2Crd reverse conversion but instead of a GFF output
		you will get a .coord or .crd output which is
		gene\tstart\tstop\tseq (for use with TransTermHP)
	-S <string> specify the string of the column 9 key for specifying value to use in BED name col\n\n";
	
}

my $file = $ARGV[0];
if(defined($opts{C})){
	open(FILE, "< $file") || die "Cannot open file $file!";
	while(my $line = <FILE>){
		if($line =~ /^#/){
		}
		else{
			chomp($line);
			my @tabs = split("\t", $line);
			if($tabs[5] =~ /-/){
				print "$tabs[3]\t$tabs[2]\t$tabs[1]\t$tabs[0]\n";
			}
			else{
				print "$tabs[3]\t$tabs[1]\t$tabs[2]\t$tabs[0]\n";
			}	
		}
	}
}
elsif(defined($opts{r})){
	#my $option = $ARGV[1];
	open(FILE, "< $file") || die "Cannot open file $file!";
	print "##gff-version 3\n";
	while(my $line = <FILE>){
		if($line =~ /^#/){
		}
		else{
			chomp($line);
			my @tabs = split("\t", $line);
			my @cols;
			$cols[0] = $tabs[0];
			$cols[1] = $file;
			#$cols[2] = "gene";
			if($tabs[3] =~ /ZMOt/){
				$cols[2] = "tRNA";
			}
			elsif($tabs[3] =~ /ZMOr/){
				$cols[2] = "rRNA";
			}
			elsif($tabs[3] =~ /ZMO\d/){
				$cols[2] = "CDS";
			}
			$cols[3] = $tabs[1] + 1;
			$cols[4] = $tabs[2];
			$cols[5] = $tabs[4];
			$cols[6] = $tabs[5];
			$cols[7] = ".";
			$cols[8] = "ID=$tabs[3];Name=$tabs[3]";
			#$cols[8] = "ID=TSS";
			my $newLine = join("\t", @cols);
			print "$newLine\n";
		}
	}
}

else{
	my($name);
	open(FILE, "< $file") || die "cannot open file $file";
	while(my $line = <FILE>){
		if($line =~ /^#/){
		}
		else{
			chomp($line);
			my @tabs = split("\t", $line);
			if($tabs[8] =~ /;/){
				my @tabs2 = split(";", $tabs[8]);
				#print "$tabs2[0]\n";
				if(defined($opts{S})){
					my %tempHash;
					foreach my $T2 (@tabs2){
						my @pairs = split("=", $T2);
						$tempHash{$pairs[0]} = $pairs[1];
					}
					$name = $tempHash{$opts{S}};
				}
				elsif($tabs2[0] =~ /^ID=(\S+)_JAY291/ || $tabs2[0]=~ /ID=(\S+)/){
					$name = $1;
				}
				elsif($tabs2[0] =~ /^NAME=(\S+)/i){
					$name = $1;
				}
			}
			else{
				my @tabs2 = split("=", $tabs[8]);
				$name = $tabs2[1];
			}
			$tabs[3] = $tabs[3] - 1;
			my $newLine = join("\t", $tabs[0], $tabs[3], $tabs[4], $name, $tabs[5], $tabs[6]);
			print "$newLine\n";
		}
	}
}
