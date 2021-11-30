#! /usr/bin/perl

use strict;
use Bio::SearchIO;

if(@ARGV != 1){
  die "

********
Usage: blast2bed.pl <blast.out> > STDOUT
********

This script will produce a bed file of annotations corresponding to 
the location of query hit relative to the target database sequence\n";
}

my $blast_out = shift;
my (%bed, $strand);

my $blast_in = Bio::SearchIO -> new( -format => 'blast', -file => $blast_out);
while (my $result = $blast_in -> next_result()){
	my $query = $result -> query_name;
	#print OUT "$query\n";
	my @hits = $result -> hits;
	if(scalar(@hits) != 0){
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
			}
			else{
				$strand = "-";
			}
			my $start = ($hsp -> start('hit')) - 1;
			my $stop = $hsp -> end('hit');
			my $E = $hsp -> evalue;
	   		 $bed{$query} = join("\t", $chr, $start, $stop, $query, $E, $strand);
	 	 }
	}
	else{
    		print STDERR "No hits found for $query\n"
	}
}
foreach my $q (sort {$a cmp $b} keys %bed){
	print "$bed{$q}\n";
}
