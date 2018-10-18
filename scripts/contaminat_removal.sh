#!/bin/bash

for i in *_R1.fastq.gz; do
	F=`basename $i _R1.fastq.gz`;

CONPATH=/mnt/data1/databases/contaminants
HOSTPATH=/mnt/data1/databases/macaca_mulatta_ensemble

# Step 1: Remove leftmost primerB. Not the reverse complements
bbduk.sh in="$F"_R1.fastq.gz in2="$F"_R2.fastq.gz \
	ref=$CONPATH/primerB.fa \
	out="$F"_R1.s1.out.fastq out2="$F"_R2.s1.out.fastq \
	k=16 hdist=1 mink=11 ktrim=l restrictleft=20\
	removeifeitherbad=f ow=t \
	rcomp=f;

# Step 2: Remove read through. Reverse complement of primerB + 6 bases of the adapter
bbduk.sh in="$F"_R1.s1.out.fastq in2="$F"_R2.s1.out.fastq \
	ref=$CONPATH/rc_primerB_ad6.fa \
	out="$F"_R1.s2.out.fastq out2="$F"_R2.s2.out.fastq \
	k=16 hdist=1 mink=11 ktrim=r \
        removeifeitherbad=f ow=t \
	rcomp=f;

# Step 3: Remove additional adapter contamination
bbduk.sh in="$F"_R1.s2.out.fastq in2="$F"_R2.s2.out.fastq \
        ref=$CONPATH/nebnext_adapters.fa \
        out="$F"_R1.s3.out.fastq out2="$F"_R2.s3.out.fastq \
        k=16 hdist=1 mink=11 ktrim=r \
        removeifeitherbad=f ow=t \
        rcomp=t;

# Step 4: QC contaminant removed sequences
bbduk.sh in="$F"_R1.s3.out.fastq in2="$F"_R2.s3.out.fastq \
	out="$F"_R1.s4.out.fastq out2="$F"_R2.s4.out.fastq outs="$F"_singletons.s4.out.fastq \
	qtrim=r trimq=30 \
	maxns=2 minlength=50 \
	ow=t;

# Step 7: Combine R1 with R1-singletons
	grep -A 3 '1:N:' "$F"_singletons.s4.out.fastq | sed '/^--$/d' > "$F"_singletons_R1.out.fastq;
	grep -A	3 '2:N:' "$F"_singletons.s4.out.fastq | sed '/^--$/d' > "$F"_singletons_R2.out.fastq;

	cat "$F"_singletons_R1.out.fastq "$F"_R1.s4.out.fastq > "$F"_R1.s5.out.fastq;
	cat "$F"_singletons_R2.out.fastq "$F"_R2.s4.out.fastq >	"$F"_R2.s5.out.fastq;
done
