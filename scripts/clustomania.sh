#!/bin/bash

# Script to deduplicate and count sequences

# Set file names
for i in *_R1.s8.out.fastq; do
	F=`basename $i _R1.s8.out.fastq`;

# Remove exact duplicates
dedupe.sh in="$F"_R1.s8.out.fastq ow=t \
	out="$F"_R1.s8.deduped.out.fastq \
	ac=f;

# Deduplication 
dedupe.sh in="$F"_R1.s8.deduped.out.fastq ow=t \
	pattern="$F"_cluster%.fa \
	ac=t s=4 \
	rnc=t pbr=t \
	csf="$F"_stats.txt out="$F"_best.fasta ;

# Remove unnecessary fasta files
rm "$F"_cluster*.fa;

# Convert to fasta
reformat.sh in="$F"_best.fasta out="$F"_reformated.fasta \
	deleteinput=t fastawrap=0 \
	minlength=50 \
	ow=t;

# Parse and combine stats and contig files
# Extraact sequences
grep -v '>' "$F"_reformated.fasta | sed '1i sequence' > "$F"_seqs.txt;

# Extract sequence IDs
grep '>' "$F"_reformated.fasta | sed 's|>Cluster_||' | awk -F "," '{ print$1 }' | sort -n | sed '1i contig_ids' > "$F"_contig_ids.txt;

# Extract counts
cut -f 1-2 "$F"_stats.txt | sed 's|Cluster_||g' > "$F"_counts.txt;

# Create sequence table
paste "$F"_seqs.txt "$F"_contig_ids.txt "$F"_counts.txt > "$F"_seqtable.txt;
rm "$F"_seqs.txt "$F"_contig_ids.txt "$F"_counts.txt;

done
