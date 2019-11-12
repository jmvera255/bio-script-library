#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, @list, $name, %genome);
getopts("g:l:c:t", \%opts);


if((not defined ($opts{g})) || (not defined ($opts{l}))){
	die "\nInappropriate number of arguments provided

********
Usage: printSeq.pl <options> > STDOUT
********

where options:
	-g <genome.fa>	specifies the genome sequence to pull seq from
	-l <list.txt>	a list containing sequence names to pull from genome.fa
	-c <int>	if list.txt is tab-delimited, specify column to read
	-t		output in tab-delimited format instead of fasta\n\n";
}

###### parse list.txt, create array with desired sequence names ######
open(LIST, "< $opts{l}") || die "cannot open list $opts{l}";
while (my $line = <LIST>){
	chomp($line);
	if($line !~ /^#/){
		if(defined($opts{c})){
			my @tabs = split("\t", $line);
			push(@list, $tabs[$opts{c}]);
		}
		else{
			push(@list, $line);
		}
	}
}
close(LIST);

###### parse genome.fa, create a hash: genome{name} = seq #######
my $seq = "";
open(GENOME, "< $opts{g}") || die "Cannot open genome $opts{g}!\n";
while(my $line = <GENOME>){
	chomp($line);
	if($line =~/^>(\S+)/){
		$name = $1;
		$seq = "";
	}
	else{
		$seq = $seq . $line;
		$genome{$name} = $seq;
	}
}
close(GENOME);


###### print requested sequences in fasta format ####
for my $S (@list){
	if(defined($genome{$S})){
		if(defined($opts{t})){
			my $line = "$S\t$genome{$S}";
			print "$line\n";
		}
		else{
			my $line = ">$S\n$genome{$S}";
			print "$line\n";
		}
	}
}


