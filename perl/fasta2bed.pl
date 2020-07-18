#! /usr/bin/perl

use strict;
use Bio::SearchIO;

if(@ARGV != 3){
	die "

********
Usage: fasta2gff.pl <genome.fa> <out.gff3> <seq.fa>
********\n";
}

my $genome = shift;
my $BED = shift;
my (%bed, $strand, $color);

open(OUT, "> $BED");

system "/opt/bifxapps/blat/blat $genome $ARGV[0] -out=blast temp.blast";

my $blast_in = Bio::SearchIO -> new( -format => 'blast', -file => 'temp.blast');
while (my $result = $blast_in -> next_result()){
	my $query = $result -> query_name;
	#print OUT "$query\n";
	my @hits = $result -> hits;
	@hits = sort {$a -> bits <=> $b -> bits} @hits;
	my $hit = pop(@hits);
	my $chr = $hit-> name;
	my @hsps = $hit-> hsps;
	@hsps = sort{$a -> bits <=> $b -> bits} @hsps;
	my $hsp = pop(@hsps);
	if(defined $hsp){
		my $test = $hsp -> strand('hit');
		if($test== 1){
			$strand = "+";
			$color = "238,0,0";
		}
		else{
			$strand = "-";
			$color = "0,0,175"
		}
		my $start = ($hsp -> start('hit')) - 1;
		my $stop = $hsp -> end('hit');
		my $E = $hsp -> evalue;
		$bed{$query} = join("\t", $chr, $start, $stop, $query, $E, $strand, $start, $stop, $color);
	}
	else{
	}
}
foreach my $q (sort {$a cmp $b} keys %bed){
	print OUT "$bed{$q}\n";
}
