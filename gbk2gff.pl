#! /usr/bin/perl

use strict;

if(@ARGV != 2){
    die "\nInappropriate number of arguments provided!

***********
Usage: perl gbk2gff.pl <file.gbk> <chr_name> > STDOUT
***********\n\n";
}

my $gbkIn = shift;
my $chr = shift;

my(%gff, $strand, @coords, $name, $locus, %attr, $test, @note);

open(GBK, "< $gbkIn") || die "\nScript aborted, cannot open $gbkIn\n";
while(my $line =<GBK>){
    chomp($line);
    if($line =~ /^     CDS/ || $line =~ /^     tRNA/ || $line =~ /^     rRNA/){
        if($line =~ /complement\((\S+)\)/){
            @coords = split(/\Q../, $1);
            $strand = "-";
        }
        elsif($line =~ /CDS             (\S+)/ || $line =~ /tRNA            (\S+)/ || $line =~ /rRNA            (\S+)/){
            @coords = split(/\Q../, $1);
            $strand = "+";
        }
    }
    elsif($line =~ /\/gene="(\S+)"/){
        $name = $1;
    }
    elsif($line =~ /\/locus_tag="(\S+)"/){
        $locus = $1;
    }
    elsif($line =~ /\/product=/){
        my @temp = split("\"", $line);
        push(@{$attr{$locus}}, "gene_id=" . $locus);
        push(@{$attr{$locus}}, "gene_name=" . $name);
        push(@{$attr{$locus}}, "product=" . $temp[1]);
        push(@{$gff{$locus}}, $chr, $gbkIn, "CDS", $coords[0], $coords[1], ".", $strand, "1");
    }
    elsif($line =~ /\/note="/){
	if($line =~ /\/note="putative/){
		my @temp = split("\"", $line);
		push(@{$attr{$locus}}, "note=" . $temp[1]);
	}
	else{
		if($line =~ /"$/){
			my @temp = split("\"", $line);
			push(@{$attr{$locus}}, "note=" . $temp[1]);
		}
		else{
			my @temp = split("\"", $line);
			push(@note, $temp[1]);
			$test = "note";
		}
	}
     }
    elsif($line =~ /\/translation="/){
	$test = "trans";
    }
    if(($line !~ /\//) && ($test =~ /note/)){
	if($line !~ /"/){
		my @temp = split("                     ", $line);
		push(@note, $temp[1]);
	}
	elsif($line =~ /"/){
		$line =~ s/"//g;
		my @temp = split("                     ", $line);
		push(@note, $temp[1]);
		#print STDERR "($temp[1])\n";
		my $N = join(" ", @note);
		push(@{$attr{$locus}}, "note=" . $N);
		@note= ();
	}
    }
}

foreach my $g (sort {$a cmp $b} keys %gff){
    my $line = join("\t", @{$gff{$g}});
    print "$line\t";
    @{$attr{$g}} =  sort {$a cmp $b} @{$attr{$g}};
    my $a = join(";", @{$attr{$g}});
    print "$a\n";
}
