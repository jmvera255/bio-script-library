#! /usr/bin/perl
# add-toc-md.pl
# this script will parse a set of markdown (md) files and add a table 
# of contents line ([TOC]) if not present

use strict;

my $usage = "
No input list of files provided!

add-toc-md.pl <list>\n\n";

#check for arg
if(@ARGV != 1){
  die $usage
}

my $file = shift;
open(FILE, "< $file") || die "Error: cannot open $file\n";
while(my $md=<FILE>){
  chomp($md);
  
  #create temp.$md file name
  my @path = split("/", $md);
  $path[(scalar(@path)-1)] = "temp." . $path[(scalar(@path)-1)];
  my $tempmd = join("/", @path) . "\n";
  print "$tempmd\n";

  open(TEMP, "> $tempmd") || die "Error: Cannot open $tempmd\n";

  #open the markdown file ($md)
  open(MD, "< $md") || die "Error: cannot open $md\n";

  #read lines in md file 
  my $count = 1;
  my $TOC = "false";
  while(my $line=<MD>){
    chomp($line);
    if($count == 1){
      if($line =~ /^\[title/){
        print TEMP "$line\n";
        $count++;
      }
      else{
        print STDERR "no title found for: $md\n";
        $count++;
      }
    }
    elsif($count == 2){
      if($line =~ /^\[TOC/){
        print TEMP "\n[TOC]\n\n";
        $count++;
        $TOC = "true";
        #print STDERR "TOC at line 2 for $md, \$TOC = $TOC\n";
      }
      elsif($line =~ /^$/){
        print TEMP "$line\n";
        $count++;
      }
    }
    elsif($count == 3){
      if($line =~ /^\[TOC/){
        print TEMP "$line\n";
        $TOC = "true";
        $count++;
      }
      elsif($TOC =~ /false/){
        print TEMP "[TOC]\n\n$line\n";
        $count++;
      }
      else{
        #print TEMP "$line\n";
        $count++;
      }
     }
     else{
      print TEMP "$line\n";
     }
  }
  close(TEMP);
  close(MD);
}
  
