#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
my (%normCounts, %header, @headerCol, $OUTDIR);
getopts("S:O:ng:", \%opts);
my @strands = ("plus", "minus");

if(defined($opts{O})){
	$OUTDIR = $opts{O};
}
else{
	$OUTDIR = "./";
}

my $USAGE = "\nUsage: perl TSSnormCounts2bedgraph.pl <options> <normCounts.txt>

A single bedgraph file will be printed for each column 
in normCounts.txt other than Chr, Position, and Strand. Default is to print
to working directory.
	
where options are:
	-S <str>	specify the sample or condition name for output files
	-O <str>	specify and output directory
	-n		output ntcov.txt instead of bedgraph
	-g <seqstat.txt> required genome dictionary if using option -n\n\n";

if(@ARGV != 1){
	die "\nNo input file provided\n$USAGE";
}

if(defined($opts{n}) && not defined($opts{g})){
	die "\nUser must provide a genome dictionary when using option -n
to create an ntcov.txt file\n$USAGE\n";
}

my $file = shift; ##
my @bgCol = ("LChr", "Position", "Strand");


##### collect normCounts data in %normCounts
my $test = 1;
open (FILE, "< $file") || die "cannot open file $file\n";
while (my $line = <FILE>){
	chomp ($line);
	if($test == 1){
		@headerCol = split("\t", $line);
		my $c = 0;
		foreach my $t (@headerCol){
			$header{$t} = $c;
			$c++;
		}
			
	}
	else{
		my @tabs = split("\t", $line);
		for (my $i = 0; $i < scalar(@tabs) - 3; $i++){
			$normCounts{$headerCol[$i]}{$tabs[$header{$bgCol[0]}]}{$tabs[$header{$bgCol[2]}]}{$tabs[$header{$bgCol[1]}]} = $tabs[$i];
			#normCounts{Sample name}   {chromosome}               {strand}                   {position (1-based)}        = value  
		}
	}
	$test++;
}
close (FILE);

##### print ntcov.txt file instead of bedgraph
my(%dict, %ntcov);
if(defined($opts{n})){
	#print STDERR "User has requested to generate ntcov.txt files located as $OUTDIR\n";
	open(TXT, "< $opts{g}") || die "Cannot open genome dict $opts{g}!\n";
	while(my $line = <TXT>){
		chomp($line);
		my @tabs = split("\t", $line);
		$dict{$tabs[0]} = $tabs[1];
	}
	#### create %ntcov with 0 value
	#print STDERR "\@headerCol has " . scalar(@headerCol) . " elements\n"; 
	for (my $s = 0; $s < scalar(@headerCol) - 3; $s++){
		my $sample = $headerCol[$s];
		#print STDERR "$sample\n";
		foreach my $chr (keys %dict){
			foreach my $str (@strands){
				for(my $i = 1; $i <= $dict{$chr}; $i++){
					$ntcov{$sample}{$chr}{$str}{$i} = 0;
				}
			}
		}
	}
	#print STDERR "%ntcov now has " . scalar(keys(%ntcov)) . " chrom\n";
	#### fill %ntcov with values from %normCounts
	foreach my $S (keys %normCounts){
		foreach my $chr (keys %{$normCounts{$S}}){
			foreach my $strand (keys %{$normCounts{$S}{$chr}}){
				foreach my $nt (keys %{$normCounts{$S}{$chr}{$strand}}){
					$ntcov{$S}{$chr}{$strand}{$nt} = $normCounts{$S}{$chr}{$strand}{$nt};
				}
			}
		}
	}

	##### generate ntcov.txt for every sample column and each strand
	foreach my $S (sort {$a cmp $b} keys %normCounts){
		foreach my $strand (@strands){
			if(defined($opts{S})){
				open(TXT, "> $OUTDIR/$opts{S}.$S.$strand.ntcov.txt") || die "Script terminated, cannot open $OUTDIR/$opts{S}.$S.$strand.ntcov.txt!\n";
			}
			else{
				open(TXT, "> $OUTDIR/$S.$strand.ntcov.txt") || die "Script terminated, cannot open $OUTDIR/$S.$strand.ntcov.txt!\n";
			}		
			foreach my $chr (keys %{$ntcov{$S}}){
				foreach my $nt (sort {$a <=> $b} keys %{$ntcov{$S}{$chr}{$strand}}){
					print TXT "$chr\t$nt\t$ntcov{$S}{$chr}{$strand}{$nt}\n";
				}
			}
			close(TXT);
		}
	}
}

elsif(not defined($opts{n})){
	##### print bedgraph files
	my($val);
	foreach my $S (sort {$a cmp $b} keys %normCounts){
		if(defined($opts{S})){
			open(BG, "> $OUTDIR/$opts{S}.$S.bedgraph") || die "Script terminated, cannot open $OUTDIR/$opts{S}.$S.bedgraph!\n";
		}
		else{
			open(BG, "> $OUTDIR/$S.bedgraph") || die "Script terminated, cannot open $OUTDIR/$S.bedgraph!\n";
		}
		print BG "track type=bedGraph\n";
	
		foreach my $chr (sort{ $a cmp $b } keys %{$normCounts{$S}}){
			foreach my $strand (sort {$a cmp $b} keys %{$normCounts{$S}{$chr}}){
				if($strand =~ /minus/){
					$val = -1;
				}
				else{
					$val = 1;
				}
				foreach my $nt (sort {$a <=> $b} keys %{$normCounts{$S}{$chr}{$strand}}){
					my $cov = $normCounts{$S}{$chr}{$strand}{$nt} * $val;
					my $start = $nt - 1;
					if($cov != 0){
						print BG "$chr\t$start\t$nt\t$cov\n";
					}
				}
			}
		}
		close(BG);
	}
}
