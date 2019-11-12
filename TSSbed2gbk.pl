#! /usr/bin/perl

use strict;
my(%bed);

my $file = shift(@ARGV);
open(BED, "< $file") || die "Cannot open $file!!\n\n";
while(my $line = <BED>){
	chomp($line);
	my @tabs = split("\t", $line);
	push(@{$bed{$tabs[3]}}, @tabs);
}

foreach my $g (keys %bed){
	my $start = $bed{$g}[1] + 1;
	if($bed{$g}[5] =~ /-/){
		print "     misc_RNA        complement($start..$bed{$g}[2])\n";
	}
	else{
		print "     misc_RNA        $start..$bed{$g}[2]\n";
	}
	print "                     /locus_tag=\"$g\"\n";
	print "                     /note=\"Result of pilot TSS study by J.Vera 3.10.17\"\n";
	print "                     /note=\"Pilot sample grown in ZRMG, collected mig-log phase\"\n";
	print "                     /note=\"Rpph(+) coverage = $bed{$g}[4]\"\n";
}
