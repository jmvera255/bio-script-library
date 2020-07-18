#! /usr/bin/perl

use strict;

## This script will parse accounts.yaml from chtcuserapp_data repo
## to get usernames from uid for disabled accounts
## will print out parsed info from accounts.yaml if a list of UID
## is also provided

if(@ARGV < 1){
	die "\nUsage: parseAccountsYaml.pl accounts.yaml <optional:uid_list.txt> > STDOUT\n\n"
}

## set global variables
my (%accountsByName, %accountsByUid);

## run subroutines
parseInputYaml();
createUidHash();
if(@ARGV == 2){
	printResults();
}

sub parseInputYaml {
my ($userName, $val, $key);
open(FILE, "< $ARGV[0]") || die "Cannot open $ARGV[0]!\n";
while (my $line = <FILE>){
	chomp($line);
	if($line =~ /^    (\S+)$/){
		$userName = substr($1,0,length($1) - 1);
#		print "$userName\n";
	}
	elsif($line =~ /^      /){
		my @tabs = split(":", $line);
		$tabs[0] =~ /(\S+)/;
		$key = $1;
		$tabs[1] =~ s/^\s+|\s+$//g;
		if($tabs[1] =~ /'|"/){
			$val = substr($tabs[1], 1, -1);
		}
		else{
			$val = $tabs[1];
		}
#		print "$userName\t$key\t$val\n";
	}
	$accountsByName{$userName}{$key} = $val;
}}

## parse accountsByName to create accountsByUid
sub createUidHash {
	my(%temp);
	foreach my $userName (keys %accountsByName){
		my $uid = $accountsByName{$userName}{"uid"};
		$temp{$uid} = $userName;
	}
	foreach my $uid (keys %temp){
		my $userName = $temp{$uid};
		$accountsByUid{$uid}{"userName"} = $userName;
		foreach my $key (keys %{$accountsByName{$userName}}){
			#if($key != /uid|gid|pass/){
				#print "$uid\t$userName\t$key\n";
				#print "$uid\t($key)\t($accountsByName{$userName}{$key})\n";
				$accountsByUid{$uid}{$key} = $accountsByName{$userName}{$key};
			#}
		}
	}
}

sub printResults {
	open(FILE, "< $ARGV[1]") || die "Cannot open file $ARGV[1]!\n";
	while(my $line =<FILE>){
		chomp($line);
		if($accountsByUid{$line}){
			my @outLine;
			push(@outLine, $line, $accountsByUid{$line}{'userName'}, 
				$accountsByUid{$line}{'fullname'}, $accountsByUid{$line}{'email'});
			print join("\t", @outLine) . "\n";
		}
	}
}
