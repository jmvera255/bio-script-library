#! /usr/bin/perl


my %gff;
open(GFF, "< $ARGV[0]") || die "Cannot open provided gff3 file $ARGV[0]!";
while(my $line =<GFF>){
	chomp($line);
	if($line !~ /^#/){
		my @tabs = split("\t", $line);
		if($tabs[2] =~ /region/){
		}
		else{
			my @tabs2 = split(";", $tabs[8]);
			my %temp;
			foreach my $c9 (@tabs2){
				my @pairs = split("=", $c9);
				$temp{$pairs[0]} = $pairs[1];
			}
			if($tabs[2] =~ /gene/){
				$temp{ID} =~ /gene-(\S+)/;
				if(defined($temp{old_locus_tag})){
					$gff{$1}{old_locus_tag} = $temp{old_locus_tag};
				}
				else{
					$gff{$1}{old_locus_tag} = "N/A";
				}
				$gff{$1}{gbkey} = $temp{gbkey};
				$gff{$1}{gene_biotype} = $temp{gene_biotype};
			}
			elsif($tabs[2] =~ /CDS/){
				$temp{Parent} =~ /gene-(\S+)/;
				#my $id = $1;
				$gff{$1}{gene} = $temp{gene};
				$gff{$1}{Dbxref} = $temp{Dbxref};
				$gff{$1}{product} = $temp{product};
				$gff{$1}{inference} = $temp{inference};
				$gff{$1}{protein_id} = $temp{protein_id};
				$gff{$1}{Note} = $temp{Note};
				$gff{$1}{CDS} = "TRUE";
			}	
		}
	}
}

foreach my $G (sort {$a cmp $b} keys %gff){
	print "$G";
	foreach my $key (keys %{$gff{$G}}){
		print "\t$key=$gff{$G}{$key}";
	}
	print "\n";
}		
