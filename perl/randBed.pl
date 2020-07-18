#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts);
getopts("og:b:", \%opts);

if(@ARGV != 1 || not defined($opts{g})){
	die "
Inappropriate number of files provided!

********
Usage: randBed.pl <options> <file.bed> <strain> > STDOUT
********

options:
	-o	no same strand overlaps
	-b <int> ?????
	-g <seqstat.txt>\n";
}

my $bedFile = shift;
my(%rand, %genome, %lengths, @chr, %strand, @lines, $lineT);
#my $dir2 = "/home/GLBRCORG/jessica.vera/Genomes";
#my %genomes =("Zm4","$dir2/Z.mobilis/Zm4/Zm4.seqstat.txt");
my $bedtools = "/opt/bifxapps/bedtools2-2.20.1/bin";

###########_parse_seqstat_##########
#open(GENOME, "< $genomes{$y}") || die "Cannot open genome file $genome{$y}";
open(GENOME, "< $opts{g}") || die "Cannot open genome file $opts{g}!\n";
while(my $line = <GENOME>){
	chomp($line);
	my @tabs = split("\t", $line);
	$genome{$tabs[0]} = $tabs[1];
	push(@chr, $tabs[0]);
}

#########_parse_bed_model_get_length_distribution##########
open(BED, "< $bedFile") || die "Cannot open $bedFile";
while (my $line = <BED>){
	chomp($line);
	my @tabs = split("\t", $line);
	my $a = $tabs[2] - $tabs[1];
	$lengths{$a}++;
	push(@{$strand{$a}}, $tabs[5]);
}

########	
if(defined $opts{o}){
	print STDERR "The user has requested that there are not same strand overlaps\n";
	my $count = 1;
	my $a = scalar(@chr);	
	foreach my $l (keys %lengths){
		for(my $i = 0; $i < $lengths{$l}; $i++){
			my $line = randAnnotate($a, $l, $i);
			if($count == 1){
				print "$line\n";
				push(@lines, $line);
			}
			else{
				my @lineCount = ();
				open(TEST, "> test.bed");
				print TEST "$line\n";
				foreach my $L (@lines){
					print TEST "$L\n";
				}
				system "/bin/sort -k1,1 -k2,2n test.bed > test.sorted.bed";
				system "$bedtools/mergeBed -s -c 4 -o collapse -i test.sorted.bed > temp.mergebed";
				open(MERGE, "< temp.mergebed") || die "Cannot open temp.mergebed";
				while(my $line2 = <MERGE>){
					chomp($line2);
					if($line2 =~ /,/){
						push(@lineCount, $line2);
					}
				}
				if(scalar(@lineCount) > 0){
					until(scalar(@lineCount) == 0){
						$line = randAnnotate($a, $l, $i);
						@lineCount = ();
						open(TEST, "> test.bed");
						print TEST "$line\n";
						foreach my $L (@lines){
							print TEST "$L\n";
						}
						system "/bin/sort -k1,1 -k2,2n test.bed > test.sorted.bed";
						system "$bedtools/mergeBed -s -c 4 -o collapse -i test.sorted.bed > temp.mergebed";
						open(MERGE, "< temp.mergebed") || die "Cannot open temp.mergebed";
						while(my $line2 = <MERGE>){
							chomp($line2);
							if($line2 =~ /,/){
								push(@lineCount, $line2);
							}
						}
					}
					print "$line\n";
					push(@lines, $line);
				}
				else{
					print "$line\n";
					push(@lines, $line);
				}
			}
		}
		$count++;
	}
}

else{
	my $a = scalar(@chr);	
	foreach my $l (keys %lengths){
		for(my $i = 0; $i < $lengths{$l}; $i++){
			my @tabs;
			my $z = int(rand($a));
			$tabs[0] = $chr[$z];	
			if($l > $genome{$tabs[0]}){
				until($l < $genome{$tabs[0]}){
					$z = int(rand($a));
					$tabs[0] = $chr[$z];
				}
			}
			my $y = $genome{$tabs[0]} - $l;
			$tabs[1] = int(rand($y));
			if(defined $opts{b}){
				$tabs[1] = $tabs[1] + $opts{b};
			}
			$tabs[2] = $tabs[1] + $l;
			$tabs[3] = $i;
			$tabs[4] = $l;
			$tabs[5] = $strand{$l}[$i];
			my $line = join("\t", @tabs);
			print "$line\n";
		}
	}
}

sub randAnnotate {
	my $a = $_[0];
	my $l = $_[1];
	my $i = $_[2];
	my @tabs;
	my $z = int(rand($a));
	$tabs[0] = $chr[$z];	
	if($l > $genome{$tabs[0]}){
		until($l < $genome{$tabs[0]}){
			$z = int(rand($a));
			$tabs[0] = $chr[$z];
		}
	}
	my $y = $genome{$tabs[0]} - $l;
	$tabs[1] = int(rand($y));
	if(defined $opts{b}){
		$tabs[1] = $tabs[1] + $opts{b};
	}
	$tabs[2] = $tabs[1] + $l;
	$tabs[3] = $i;
	$tabs[4] = $l;
	$tabs[5] = $strand{$l}[$i];
	return(join("\t", @tabs));
}

