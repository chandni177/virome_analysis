#!/bin/bash


for i in *_R1.s5.out.fastq; do
	F=`basename $i _R1.s5.out.fastq`;

	# Deduplication 
	dedupe.sh in="$F"_R1.s5.out.fastq ow=t \
	pattern=cluster%.fa \
	ac=t am=t s=4 \
	rnc=t pbr=t \
	csf=stats.txt out=best.fasta ;

	rm *.fa;
	reformat.sh in=best.fasta out=reformated.fasta deleteinput=t fastawrap=0

	# Parse and combine stats and contig files
	grep -v '>' reformated.fasta | sed '1i sequence' > seqs;
	grep '>' reformated.fasta | sed 's|>Cluster_||' | awk -F "," '{ print$1 }' | sort -n | sed '1i contig_ids' > contig.ids;
	cut -f 1-2 stats.txt | sed 's|Cluster_||g' > counts;

	# Create sequence table
	paste seqs contig.ids counts > seqtable;

done
