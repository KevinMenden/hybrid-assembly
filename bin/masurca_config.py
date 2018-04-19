#!/usr/bin/env python

##################################
## Creates MaSuRCA config file ###
##################################

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--sr1", help="Path to short reads 1")
parser.add_argument("--sr2", help="Path to short reads 2")
parser.add_argument("--isize", help="The mean insert size. Default: 180", default="180")
parser.add_argument("--stdev", help="The insert size standard deviation. Default: 20", default="20")
parser.add_argument("--lr", help="Path to long reads")
parser.add_argument("--lr_type", help="Type of long reads: nanopore | pacbio. Default: nanopore", default="nanopore")
parser.add_argument("--high_cov", help="Set this flag if you have high coverage", default=False, action="store_true")
parser.add_argument("--genome_size", help="The genome size in bp. Default: 2100000000", default=2100000000)
parser.add_argument("-p", help="Cores to use", default=16)
parser.add_argument("--close_gaps", help="Whether gaps should be closed. Default: False.", default=False, action="store_true")

args = parser.parse_args()

long_reads = ""
if args.lr_type == 'nanopore':
    long_reads = "NANOPORE=" + args.lr
elif args.lr_type == 'pacbio':
    long_reads = "PACBIO=" + args.lr
else:
    print("Invalid long read type specification in masurca_config.py. Use either 'nanopore' or 'pacbio' for the --lr_type flag.")

linking_mates = "1"
if args.high_cov:
    linking_mates == "0"

jf_size = str(10 * int(args.genome_size))

isize = args.isize
stdev = args.stdev
sr1 = args.sr1
sr2 = args.sr2
cores = args.p
close_gaps = args.close_gaps

masurca_config = """
DATA
PE= pe %(isize)s %(stdev)s  %(sr1)s  %(sr2)s
%(long_reads)s 
END

PARAMETERS
EXTEND_JUMP_READS=0
GRAPH_KMER_SIZE = auto
USE_LINKING_MATES = %(linking_mates)s
USE_GRID=0
GRID_QUEUE=all.q
GRID_BATCH_SIZE=300000000
LHE_COVERAGE=30
LIMIT_JUMP_COVERAGE = 300
CA_PARAMETERS =  cgwErrorRate=0.15
KMER_COUNT_THRESHOLD = 1
CLOSE_GAPS=%(close_gaps)s
NUM_THREADS = %(cores)s
JF_SIZE = %(jf_size)s
SOAP_ASSEMBLY=0
END

""" % globals()

nf = open("masurca_config.txt", "w")
nf.write(masurca_config)
nf.close()