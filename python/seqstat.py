### seqstat.py
### for each sequence in input fasta, return seq name and length
### in tab-delimited list

import sys
from Bio import SeqIO

def usage():
    print("\n""""No FASTA file provided!

*********
Usage: python seqstat.py <in.fasta> > STDOUT
*********

This script will take a fasta file and return a tab-delimited report
of the sequence name and sequence length of each sequence in the fasta
file. Will work for both nucleic acid and amino acid sequences.

For questions see Jessica Vera.

This script was written by Jessica M. Vera""""\n")

def seqstat(fasta):
    for seq_record in SeqIO.parse(fasta, "fasta"):
        print(seq_record.id, "\t", len(seq_record))

def main(fasta):
    if len(sys.argv) != 2:
        usage()
    else:
        seqstat(fasta)

main(sys.argv[1])
