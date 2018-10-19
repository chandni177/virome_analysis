#!/bin/sh

# Script to blastx deduplicated sequences against a virus sequence database

# Set variables
BLASTX_DB=/mnt/data1/databases/viroDB_nr/viruSITE_2018_update/prot/viroDB_prot
EV=1e-3
mkdir virodb_virusite_blastx_out

# Set filenames
for i in *_reformated.fasta; do
	F=`basename $i _reformated.fasta`;

# Run blast	
blastx -num_threads 64 \
	-query "$F"_reformated.fasta \
	-db $BLASTX_DB \
	-evalue $EV \
	-num_alignments 250 -num_descriptions 250 \
	-out ./virodb_virusite_blastx_out/"$F"_R1.virodb_virusite.blastx;

done
