#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, @list, $name, %genome);
getopts("f:l:c:tn:", \%opts);

if(not defined($opts{f})){
	die "\nInappropriate number of arguments provided

********
Usage: printSeq.pl <options> > STDOUT
********

where options:
  -f   <file.fa> specifies the genome sequence to pull seq from
  -l   <list.txt> a list containing sequence names to pull from file.fa
       this list in one name per line
  -c   <int> if list.txt is tab-delimited, specify column to read
  -t   output in tab-delimited format instead of fasta
  -n   <string> allows for a single seq name to be specified from the
       command line

This script will take a list of sequence names and return only those sequences if
those sequences are found in the provided file.fa. Good for selecting a subset of sequences
of interest from a larger set of sequences in the file.fa

This script was written by Jessica M. Vera, for questions please contact her.\n\n";
}

###### parse list.txt, create array with desired sequence names ######
if(defined($opts{l})){
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
}
elsif(defined($opts{n})){
  push(@list, $opts{n});
}

###### parse genome.fa, create a hash: genome{name} = seq #######
my $seq = "";
open(GENOME, "< $opts{f}") || die "Cannot open file.fa $opts{g}!\n";
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
