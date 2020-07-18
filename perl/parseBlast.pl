#!/usr/bin/perl

use strict;
use Bio::SearchIO; 

if(@ARGV != 1){
	die "
You must provide a blast file.

********
Usage: parseBlast.pl <out.blast> > STDOUT
********\n";
}
my($test, %chrConvert);
my $fileBlast = shift;
my %strandConvert = ("1", "+", "-1", "-");
$chrConvert{S288c} = 		{"YA"=> "chr01", 
				"YB"=> "chr02",
				"YC"=> "chr03", 
				"YD"=> "chr04",
				"YE"=> "chr05", 
				"YF"=> "chr06", 
				"YG"=> "chr07", 
				"YH"=> "chr08", 
				"YI"=> "chr09", 
				"YJ"=> "chr10", 
				"YK"=> "chr11", 
				"YL"=> "chr12", 
				"YM"=> "chr13", 
				"YN"=> "chr14", 
				"YO"=> "chr15", 
				"YP"=> "chr16"};
  
$chrConvert{Sigma} = 		{"YA"=> "chr1", 
				"YB"=> "chr2", 
				"YC"=> "chr3", 
				"YD"=> "chr4",
				"YE"=> "chr5", 
				"YF"=> "chr6", 
				"YG"=> "chr7", 
				"YH"=> "chr8", 
				"YI"=> "chr9", 
				"YJ"=> "chr10", 
				"YK"=> "chr11", 
				"YL"=> "chr12", 
				"YM"=> "chr13", 
				"YN"=> "chr14", 
				"YO"=> "chr15", 
				"YP"=> "chr16"}; 
open(OUT2, "> parseBlast.noHits.txt");


my $in = new Bio::SearchIO(-format => 'blast', 
                           -file   => $fileBlast);
while( my $result = $in->next_result) {  #result is a Bio::Search::Result::ResultI compliant object
	#while(my $hit = $result->next_hit) {  #hit is a Bio::Search::Hit::HitI compliant object
	my $name = $result->query_name;
	$name =~ /(Y.)/;
	#print "$name\t$1\n";
	my $x = $1;
	if($fileBlast =~ /Sigma/i){
		$test = $chrConvert{Sigma}{$x};
		#print "$name\t$x\t$test\n";
	}
	else{
		$test = $chrConvert{S288c}{$x};
	}	
	if($result->num_hits ==0){
		print OUT2 $result->query_name, "\n";
	}
	else{
		my @hits = $result->hits;
		@hits = sort {$b->bits <=> $a->bits} @hits;
		my @hsp = $hits[0] ->hsps;
 		@hsp = sort { $b->bits <=> $a->bits } @hsp;
		my $best = $hsp[0];
		push(my @line, $hits[0]->name, $best->start('hit') - 1, $best->end('hit'), $result->query_name, $hits[0]->num_hsps, $strandConvert{$best->strand('hit')});
		my $newLine=join("\t", @line);
		if($hits[0]->name =~ /^$test$/){
			print "$newLine\n";
		}
		else{
			#print OUT2 $result->query_name, "\n";
			print OUT2 "$newLine\n";
		}
			
	}
}


#}
# my @hits = $result->hits;
# for my $hit ( sort { $a->bits <=> $b->bits } @hits ) {
#
#
#
#		while( my $hsp = $hit->next_hsp ) {
#                   $hsp is a Bio::Search::HSP::HSPI compliant object
#                        if( $hsp->length('total') > 50 ) {
#                                if ( $hsp->percent_identity >= 75 ) {
#                                          print "Query=",   $result->query_name,
#                                                      " Hit=",        $hit->name,
#                                                                  " Length=",     $hsp->length('total'),
#                                                                              " Percent_id=", $hsp->percent_identity, "\n";
#                                                                                      }
#                                                                                            }
#                                                                                                }  
#                                                                                                  }
#                                                                                                  }
