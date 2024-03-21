#! /usr/bin/env python

# printBed.py
# return specific BED features for a given list 
# of user-defined feature names

import argparse
def get_args():
    # define some strings to keep things clean
    description_str="""Return specific BED features for a given list of user defined feature names.
    This script was written by Jessica M. Vera and is available online 
    at https://github.com/jmvera255/bio-script-library"""

    c_help="""If <list.txt> contains multiple, tab-delimited columns use -c <int> 
    to specify a column from which to read. For eas of use, use -c 1 for 
    the first column, counting left-to-right."""
    
    # define command line args
    parser = argparse.ArgumentParser(description=description_str)
    parser.add_argument('-c', type=int, dest='c', help=c_help)
    parser.add_argument('list.txt', type=open, dest='user_list', 
    help='user-defined list of features to return from file.bed')
    parser.add_argument('file.bed', type=open, dest='file_bed',
    help='A 4+ column BED file')

def usage():
    print("\n""""Incorrect arguments provided!

*******
printBed.pl <options> <list.txt> <file.bed> > STDOUT
*******

This script will take a list of bed file feature names and return the 
features in the provided bed file that have that name. Good for pulling 
out a subset of features from a larger bed file.

If <list.txt> contains multiple, tab-delimited columns use -c <int> 
to specify a column from which to read. For eas of use, use -c 1 for 
the first column, counting left-to-right.

Note: The provided bed file must have at least 4 columns where the 4th 
column is used to denote the feature name.

This script was written by Jessica M. Vera and is available online 
at https://github.com/jmvera255/bio-script-library""""\n")




if __name__ == '__main__':
    main()
