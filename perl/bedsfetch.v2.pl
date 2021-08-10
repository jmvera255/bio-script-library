#! /usr/bin/perl

use strict;
use Bio::SeqIO;
use List::Util 'first';
#use Bio::SeqI;

use Getopt::Std;
my (%opts);
getopts("gtR", \%opts);

####################################
## Usage statement #################
if(@ARGV != 2){
	die "
##########
Usage: bedsfetch.pl <options> <file.bed> <genome.fa> > STDOUT
##########

where options are:
(deprecated) -g	specifies that the input is a GFF3 file
		will use Parent qualifier, else ID if none present
	     -t	output in tab-delimited format, i.e. name-tab-seq
		default is fasta format
	     -R	output RNA sequence instead of DNA\n"
}


my $bedFile = shift;
my $genome = shift; 

my($start, $stop, %bed);

###################################################
########	parse annotation file	###########
###################################################

if(defined $opts{g}){
	open(GFF, "< $bedFile") || die "Script aborted, cannot open bed file $bedFile\n";
	while(my $line =<GFF>){
		chomp($line);
		if($line !~ /^#/){
			my @tabs = split("\t", $line);
			if($tabs[6] =~ /-/){
				$start = $tabs[4];
				$stop = $tabs[3];
			}
			else{
				$start = $tabs[3];
				$stop = $tabs[4];
			}
			my $name;
			if($tabs[8] =~ /Parent/){
				my @tabs2 = split(";", $tabs[8]);
				my $match = first{/Parent=/i} @tabs2;
				$match =~ /Parent=(\S+)/;
				$name = $1;
			}
			elsif($tabs[8] =~ /;/){
				my @tabs2 = split(";", $tabs[8]);
				my $match = first{/ID=/i} @tabs2;
				$match =~ /ID=(\S+)/;
				$name = $1;
			}
			else{
				if($tabs[8] =~ /ID=(\S+)/){
					$name=$1;
				}
				else{
					print STDERR "No name found for feature at $line\n";
				}
			}
			push(@{$bed{$tabs[0]}{$name}}, $start, $stop);
		}
	}
}	

else{
	open(BED, "< $bedFile") || die "Script aborted, cannot open bed file $bedFile\n";
	while(my $line =<BED>){
		chomp($line);
		if($line =~ /^#/){
		}
		else{
			my @tabs = split("\t", $line);
			if($tabs[5] =~ /-/){
				$start = $tabs[2];
				$stop = $tabs[1] + 1;
			}
			else{
				$start = $tabs[1] + 1;
				$stop = $tabs[2];
			}
			# allow for redundant feature names
			push(@{$bed{$tabs[0]}{join("_", $start, $stop)}},$tabs[3], $tabs[5]);
			#push(@{$bed{$tabs[0]}{$tabs[3]}}, $start, $stop, $tabs[5]);
		}
	}
}

######################################
## print out sequences ###############
######################################
foreach my $chr (sort {$a cmp $b} keys %bed){
	my $seqio_object = Bio::SeqIO->new(-file => $genome, -format => 'fasta'); 
	my $seq = $seqio_object->next_seq();
	until($seq -> id =~ /$chr/){
		$seq = $seqio_object->next_seq();
	}
	my $t = $seq -> id;
	foreach my $f (sort {$a cmp $b} keys %{$bed{$chr}}){
		my $seq_out;
		my @coord = split("_", $f);
		if($bed{$chr}{$f}[1] =~ /-/){
			my ($substring, $rev, $seq_in, $seq2);
			my $outSeq = $seq -> subseq($coord[1], $coord[0]);
			if(defined($opts{R})){
				my @outRNA;
				$outSeq =~ tr/ATGC/UACG/;
				my @temp = split("", $outSeq);
				for(my $i = scalar(@temp) - 1; $i >=0; $i--){
					push(@outRNA, $temp[$i]);
				}
				my $RNA = join("", @outRNA);
				$substring = join("\n", ">$bed{$chr}{$f}[0]", $RNA);
				$seq_in = Bio::SeqIO->new(-string => $substring);
				$seq2 = $seq_in -> next_seq();
			}
			else{
				$substring = join("\n", ">$bed{$chr}{$f}[0]", $outSeq);
				$seq_in = Bio::SeqIO->new(-string => $substring);
				$seq2 = $seq_in -> next_seq();
				$rev = $seq2 -> revcom;
			}
			if(defined $opts{t}){
				$seq_out= Bio::SeqIO->new(-format => 'tab');
			}
			else{
				$seq_out= Bio::SeqIO->new(-format => 'fasta');
			}
			if(defined($opts{R})){
				$seq_out ->write_seq($seq2);
			}
			else{
				$seq_out ->write_seq($rev);
			}
		}
		elsif($bed{$chr}{$f}[2] !~ /-/){
			my $outSeq = $seq -> subseq($coord[0], $coord[1]);
			if(defined($opts{R})){
				$outSeq =~ tr/T/U/;
			}
			my $substring = join("\n", ">$bed{$chr}{$f}[0]", $outSeq);
			my $seq_in = Bio::SeqIO->new(-string => $substring);
			my $seq = $seq_in -> next_seq();
			if(defined $opts{t}){
				$seq_out= Bio::SeqIO->new(-format => 'tab');
			}
			else{
				$seq_out= Bio::SeqIO->new(-format => 'fasta');
			}
			$seq_out ->write_seq($seq);
		}
	}
}
