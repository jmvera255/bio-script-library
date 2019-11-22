#! /usr/bin/perl

use strict;
use Getopt::Std;
use List::Util qw( min max );

my (%opts);
getopts("g,G,M,a,n,E,m:,p:,h:,i", \%opts);

my $usage = "*********
Usage: bed2ntcov.pl <options> <file.bed> > STDOUT
********

This script is used for compiling various quantitative data from read mapping 
corresponding to regions in the genome that are annotated in the provided bed file.

Examples for using this script include compiling cummulative (-E) or average (-a) read coverage across
a gene, making tables of metagene plots (-g), finding the highest coverage value in a region -M), etc.

Note: This script is designed to work with stranded ntcov.txt files. These files are generated 
using bedTools genomeCovBed with -d parameter which will make genomeCoverageBed report read depth 
at each genome position with one-based coordinates

Note: This script by default expects stranded data (i.e. RNA-seq). In the case of ChIP-seq data, 
use the -i option to specify that the data is not stranded; only use -p to provide ntcov.txt file 

where options are:
-a	print out average over length of bed feature; returns a bed file with average as score (default)
-n	print value of each nt in bed feature (exclusive with -a)
-E	print sum of coverage along feature; returns bed file w/score
-m	minus strand coverage ntcov.txt, any number can be provided in a comma-delimited list
-p	plus strand coverage ntcov.txt, any number can be provided in a comma-delimited list
-G	return results sorted by gene name; default is to print in order of bed file
-g	return per nucleotide values in columns with single gene as row; sorted by gene name
	and columns ordered strand specifically
-M	return max per nucleotide value per feature
-h	specify column header (intended for use with -n option only)
-i	specifies that the data is not stranded (e.g. ChIP-seq data)

if ntcov.txt files provided from multiple samples then the reported value will be the average across
these samples, independent of option choosen

This script was written by Jessica M. Vera, for questions please contact her.\n\n";

if(@ARGV != 1){
	die "
\nNo bed file provided!\n\n$usage";
}

if((not defined($opts{p}) and not defined($opts{m})) and (not defined($opts{i}))){
	die "
\nUser must provided both a plus and minus strand ntcov.txt file OR
use -i option to specify that the data is not stranded!\n\n$usage";
}

###############################################################################
my $bedFile = shift;
my(%ntcov, %count, $sum, @temp, $strand, @files, %byGene, %geneStarts);
my(%lines, %sums);

##########_parse ntcovt.txt files_##########
if($opts{p} =~ /,/){
	@files = split(",", $opts{p});
	print STDERR "Multiple plus files provided!\n";
}
else{
	push(@files, $opts{p});
}
foreach my $file (@files){
#	print STDERR "Processing $file\n";
	if(defined $opts{i} and not defined $opts{p}){
		die "\nWhen using the -i option you must provide the ntcov.txt file via the -p parameter\n\n$usage\n\n";
	}
	open(PLUS, "< $file") || die "cannot open file $file!";
	while (my $line = <PLUS>){
		chomp($line);
		my @cols = split("\t", $line);
		$cols[3] = "+";
		$count{$cols[0]}{$cols[3]}{$cols[1]}++;
		if($ntcov{$cols[0]}{$cols[3]}{$cols[1]}){
			my $a = $ntcov{$cols[0]}{$cols[3]}{$cols[1]};
			$a = ($a + $cols[2])/$count{$cols[0]}{$cols[3]}{$cols[1]};
			$ntcov{$cols[0]}{$cols[3]}{$cols[1]} = $a;
		}
		else{
			$ntcov{$cols[0]}{$cols[3]}{$cols[1]} = $cols[2];
		}
	}
	close(PLUS);
}
@files = ();

if(defined $opts{i}){
}
else{
	if($opts{m} =~ /,/){
		@files = split(",", $opts{m});
		print STDERR "Multiple minus files provided!\n";
	}
	else{
		push(@files, $opts{m});
	}
	foreach my $file (@files){
	#	print STDERR "Processing $file\n";
		open(MINUS, "< $file") || die "cannot open file $file!";
		while (my $line = <MINUS>){
			chomp($line);
			my @cols = split("\t", $line);
			$cols[3] = "-";
			$count{$cols[0]}{$cols[3]}{$cols[1]}++;
			if($ntcov{$cols[0]}{$cols[3]}{$cols[1]}){
				my $a = $ntcov{$cols[0]}{$cols[3]}{$cols[1]};
				$a = ($a + $cols[2])/$count{$cols[0]}{$cols[3]}{$cols[1]};
				$ntcov{$cols[0]}{$cols[3]}{$cols[1]} = $a;
			}
			else{
				$ntcov{$cols[0]}{$cols[3]}{$cols[1]} = $cols[2];
			}
		}
		close(MINUS);
	}
}

###### print header is specified #########
if(defined $opts{h}){
	print "$opts{h}\n";
}

############_parse_bed_file_###################
my $c = 1;
open(BED, "< $bedFile") || die "Cannot open file $bedFile!";
while (my $line = <BED>){
	chomp($line);
	if($line !~ /^#/){
		my @cols = split("\t", $line);
		my $length = $cols[2] - $cols[1];
		$cols[1] = $cols[1] + 1;
		### test for stranded bed file
		if(not defined $opts{i}){
			if(scalar(@cols) < 6){
				die "User needs to provide a stranded bed file or use -i option!\n\n$usage\n\n";
			}
			else{
				if($cols[5] =~ /-/){
					for(my $i = $cols[2]; $i >= $cols[1]; $i--){
						if(defined $opts{n}){
							my $x = sprintf("%.4f", $ntcov{$cols[0]}{$cols[5]}{$i});
							print "$x\n";
							#print "$ntcov{$cols[0]}{$cols[5]}{$i}\n";
						}
						else{
							push(@temp, $ntcov{$cols[0]}{$cols[5]}{$i});
						}
					}
				}
				else{
					for(my $i = $cols[1]; $i <= $cols[2]; $i++){
						if(defined $opts{n}){
							my $x = sprintf("%.4f", $ntcov{$cols[0]}{$cols[5]}{$i});
							print "$x\n";
							#print "$ntcov{$cols[0]}{$cols[5]}{$i}\n";
						}
						else{
							push(@temp, $ntcov{$cols[0]}{$cols[5]}{$i});
						}
					}
				}
			}
		}
		##### option -i is in use and data is not stranded
		else{
			my $PlusStrand = "+";
			for(my $i = $cols[1]; $i <= $cols[2]; $i++){
				if(defined $opts{n}){
					my $x = sprintf("%.4f", $ntcov{$cols[0]}{$PlusStrand}{$i});
					print "$x\n";
				}
				else{
					push(@temp, $ntcov{$cols[0]}{$PlusStrand}{$i});
				}
			}
		}

		if(defined $opts{g} || defined $opts{M}){
			if(not defined $byGene{$cols[3]}){
				$geneStarts{$cols[3]} = $cols[1];
				@{$byGene{$cols[3]}} = @temp;
			}
			else{
				if($cols[1] > $geneStarts{$cols[3]}){
					unshift(@{$byGene{$cols[3]}}, @temp);
				}
				elsif($cols[1] < $geneStarts{$cols[3]}){
					push(@{$byGene{$cols[3]}}, @temp);
				}
			}
			@temp = ();
		}
		elsif(defined $opts{a} || not defined $opts{n}){
			if($length == 0){
			}
			else{
				$sum += $_ for @temp;
				if(defined $opts{E}){
#					print STDERR "Only the sum will be returned\n";
				}
				else{
#					print STDERR "The average is being calculated\n";
					$sum = $sum/$length;
				}
				$cols[4] = $sum;
				$cols[1] =  $cols[1] - 1;
				#unshift(@cols, $length);
				my $newLine = join("\t", @cols);
				print "$newLine\n";
				$lines{$c} = $newLine;
				if(defined $opts{G}){
					$sums{$c} = $cols[3];
				}
				else{
					$sums{$c} = $cols[4]; # sort by score
				}
				@temp = ();
				$c++;
				$sum = 0;
			}
		}
	}
}

#######_print sum or average_#########
if(defined $opts{G}){
	foreach my $k (sort {$sums{$a} cmp $sums{$b}} keys %sums){
		print "$lines{$k}\n";
	}
}
elsif(defined $opts{g} || defined $opts{M}){
	foreach my $g (sort {$a cmp $b} keys %byGene){
		if(defined $opts{M}){
			my $max = max(@{$byGene{$g}});
			print "$g\t$max\n";
		}
		else{
			my $line = join("\t", @{$byGene{$g}});
			print "$g\t$line\n";
		}
	}
}
#else{
#	foreach my $k (sort {$sums{$a} <=> $sums{$b}} keys %sums){
#		print "$lines{$k}\n";
#	}
#}
