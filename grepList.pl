#! /usr/bin/perl

use strict;
use Getopt::Std;

my (%opts, $ColNum);
getopts("c:r:di", \%opts);
if ($opts{r}){
#	print STDERR "-r $opts{r}\n";
}
else{
	 $opts{r} = 0;
}
if(defined $opts{c}){
	#print STDERR "-c $opts{c}\n";
	$ColNum = $opts{c};
}

if(@ARGV != 2){
	die "\nInapprpriate number of arguments provided!

********
Usage: grepList.pl <options> <list.txt> <grepFile>
********
  
-c	if you wish to parse a specific column of a tab-delimited
	file then you must denote column (starts at 0)

-r	opt selects a grep regex option:
	0 = regex\\t (default)
	1 = ^regex\\t
	2 = regex\$
	3 = \\tregex\$
	4 = \\tregex\\t
	5 = \\tregex_5UTR\\t
	6 = \\tregex_3UTR\\t
	7 = -w <regex>
	8 = <regex>  --> no formating
	9 = \"<regex>\"
	10 = \\tregex

-i	ignore case

-d	search redundantly\n";
}

my(%list, @list, @parameters);
if(defined $opts{i}){
	push(@parameters, "-i")
}
if(($opts{r} == 8) || ($opts{r} ==9)){
}
elsif($opts{r} == 7){
	push(@parameters, "-w");
}
else{
	push(@parameters, "-P")
}

my $param = join(" ", @parameters);
#print STDERR "$param\n";
my $reg = $opts{r};

my $listFile = $ARGV[0];
my $grepFile = $ARGV[1];
open(TEST, "< $grepFile") || die "Cannot find grep file $grepFile, job cancelled\n";
close(TEST);

open(LIST, "< $listFile") || die "cannot open file $listFile!";
while(my $line = <LIST>){
	chomp($line);
	if($line =~ /^#/){
	}
	else{
		if(defined $opts{c}){
			$ColNum = $opts{c};
			my @cols = split("\t", $line);
			$list{$cols[$ColNum]}++;
			if(defined $opts{d}){
				push(@list, $cols[$ColNum]);
			}
			elsif($list{$cols[$ColNum]} == 1){
				push(@list, $cols[$ColNum]);
			}
		}
		elsif(defined $opts{d}){
			push(@list, $line);
		}
		else{
			$list{$line}++;
			if($list{$line} == 1){
				push(@list, $line);
			}
		}
	}
}
foreach my $a (@list){
#	print "$a\n";
	#system "grep $a" . "_5UTR $grepFile"
	if($a =~ /[()]/){
		#print STDERR "$a\n";
		$a =~ s/\(/\\(/g;
		$a =~ s/\)/\\)/g;
		#print STDERR "$a\n";
	}	
#	if($a =~ /-/){
#		#print STDERR "$a\n";
#		$a =~ s/-/\\-/g;
#		#print STDERR "$a\n";
#	}	
	if($reg == 2){
		system "grep $param \"$a\$\" $grepFile"; #line ends with grep regex
	}
	elsif($reg == 1){
		system "grep $param \"^$a\\t\" $grepFile"; #line starts with grep regex followed by tab
	}
	elsif($reg == 0){
		system "grep $param \"$a\\t\" $grepFile"; #tab after grep regex
	}
	elsif($reg == 3){
		system "grep $param \"\\t$a\$\" $grepFile"; #tab before grep regex
	}
	elsif($reg == 4){
		system "grep $param \"\\t$a\\t\" $grepFile"; #tab before grep regex
	}
	elsif($reg == 5){
		system "grep $param \"\\t$a" . "_5UTR\\t\" $grepFile"; #tab before grep regex
	}
	elsif($reg == 6){
		system "grep $param \"\\t$a" . "_3UTR\\t\" $grepFile"; #tab before grep regex
	}
	elsif($reg == 7){
		system "grep $param $a $grepFile";
	}
	elsif($reg == 8){
		if(scalar(@parameters) > 0){
			system "grep $param $a $grepFile";
		}
		else{
			system "grep $a $grepFile";
		}	
	}
	elsif($reg == 9){
		system "grep \\\"\"$a\"\\\" $grepFile";
	}
	elsif($reg == 10){
		system "grep $param \"\\t$a\" $grepFile"; #tab before grep regex
	}
}

