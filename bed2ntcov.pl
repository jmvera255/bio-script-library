#! /usr/bin/perl

use strict;
use Getopt::Std;
use List::Util qw( min max );
use List::MoreUtils 'first_index';

my (%opts);
getopts("g,G,M:,a,n,E,S,m:,p:,h:", \%opts);

if(@ARGV != 1){
	die "
Inappropriate number of arguments provided!

*********
Usage: bed2ntcov.pl <options> <file.bed> > STDOUT
********

where options are:
-a	print out average over length of bed feature; returns a bed file with average as score (default)
-n	print value of each nt in bed feature (exclusive with -a)
-E	print sum of coverage along feature; returns bed file w/score
-S	ignore strandedness
-m	minus strand coverage ntcov.txt
-p	plus strand coverage ntcov.txt
-G	return results sorted by gene name; default is to print in order of bed file
-g	return per nucleotide values in columns with single gene as row; sorted by gene name
	and columns ordered strand specifically
-M <int>	1 = return max per nucleotide value per feature, 2 = return max value, 0-based position, and strand
-h	specify column header (intended for use with -n option only)

if ntcov.txt files provided from multiple samples
then the reported value will be the average across
these samples, independent of option choosen\n";
}

my $bedFile = shift;
my(%ntcov, %count, $sum, @temp, $strand, @files, %byGene, %geneStarts, %geneStarts2);
my(%lines, %sums);

############################################
##########_parse ntcovt.txt files_##########
############################################
if($opts{p} =~ /,/){
	@files = split(",", $opts{p});
#	print STDERR "Multiple plus files provided!\n";
}
else{
	push(@files, $opts{p});
}
foreach my $file (@files){
#	print STDERR "Processing $file\n";
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

if($opts{m} =~ /,/){
	@files = split(",", $opts{m});
#	print STDERR "Multiple plus files provided!\n";
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

if(defined $opts{h}){
	print "$opts{h}\n";
}

###############################################
############_parse_bed_file_###################
###############################################
my $c = 1;
open(BED, "< $bedFile") || die "Cannot open file $bedFile!";
while (my $line = <BED>){
	chomp($line);
	if($line !~ /^#/){
	my @cols = split("\t", $line);
	my $length = $cols[2] - $cols[1];
	$cols[1] = $cols[1] + 1;
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
	if(defined $opts{g} || defined $opts{M}){
		if(not defined $byGene{$cols[3]}){
			$geneStarts{$cols[3]} = $cols[1];
			@{$byGene{$cols[3]}} = @temp;
			if($cols[5] =~ /-/){
				push(@{$geneStarts2{$cols[3]}}, $cols[2], "-", $cols[0])
			}
			else{
				push(@{$geneStarts2{$cols[3]}}, $cols[1], "+", $cols[0])
			}
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
#				print STDERR "Only the sum will be returned\n";
			}
			else{
#				print STDERR "The average is being calculated\n";
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
}}

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
			my $index = first_index { /$max/ } @{$byGene{$g}};
			if($opts{M} ==1){
				print "$g\t$max\n";
			}
			elsif($opts{M}==2){
				my $pos;
				if($geneStarts2{$g}[1] =~ /-/){
					$pos = $geneStarts2{$g}[0] - $index;
					my $pos2 = $pos - 1;
					#print "$g\t$max\t$pos\t$geneStarts2{$g}[1]\t$index\t$geneStarts2{$g}[0]\n";
					print "$geneStarts2{$g}[2]\t$pos2\t$pos\t$g\t$max\t$geneStarts2{$g}[1]\n";
				}
				else{
					$pos = $geneStarts2{$g}[0] + $index - 1;
					my $pos2 = $pos + 1;
					#print "$g\t$max\t$pos\t$geneStarts2{$g}[1]\t$index\t$geneStarts2{$g}[0]\n";
					print "$geneStarts2{$g}[2]\t$pos\t$pos2\t$g\t$max\t$geneStarts2{$g}[1]\n";
				}
			}
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
