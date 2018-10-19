#!/bin/bash

# Script to remove non-biological sequences (primers, adapters), low-quality bases and host-sequences from virome sequenced libraries

# Summary:
# Step 1: Remove leftmost primerB. Not the reverse complements
# Step 2: Remove read through. Reverse complement of primerB + 6 bases of the adapter
# Step 3: Remove additional (primer free) adapter contamination
# Step 4: Remove any remaining sequence which contains any primer in either orientation
# Step 5: PhiX Removal
# Step 6: Host-removal
# Step 7: QC contaminant removed sequences
# Step 8: Read merge
# Step 9: Read repair

# Set Variables
CONPATH=/mnt/data1/databases/contaminants
HOSTPATH=/mnt/data1/databases/macaca_mulatta_ensemble

# Set file names
for i in *_R1.fastq.gz; do
	F=`basename $i _R1.fastq.gz`;

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

# Step 3: Remove additional (primer free) adapter contamination
bbduk.sh in="$F"_R1.s2.out.fastq in2="$F"_R2.s2.out.fastq \
        ref=$CONPATH/nebnext_adapters.fa \
        out="$F"_R1.s3.out.fastq out2="$F"_R2.s3.out.fastq \
        k=16 hdist=1 mink=11 ktrim=r \
        removeifeitherbad=f ow=t \
        rcomp=t;

# Step 4: Remove any remaining sequence which contains any primer in either orientation
bbduk.sh in="$F"_R1.s3.out.fastq in2="$F"_R2.s3.out.fastq \
	ref=$CONPATH/rc_primerB_ad6.fa \
	out="$F"_R1.s4.out.fastq out2="$F"_R2.s4.out.fastq \
	k=16 ow=t hdist=0 \
	rcomp=t;

# Step 5: PhiX Removal
bbduk.sh in="$F"_R1.s4.out.fastq in2="$F"_R2.s4.out.fastq \
	ref=$CONPATH/phix174_ill.ref.fa.gz \
	out="$F"_R1.s5.out.fastq out2="$F"_R2.s5.out.fastq \
	k=31 hammingdistance=1 ow=t;

# Step 6: Host-removal
bbmap.sh in="$F"_R1.s5.out.fastq in2="$F"_R2.s5.out.fastq \
	out="$F"_unmapped.s6.out.fastq outm="$F"_hostmapped.s6.out.fastq \
	minid=0.95 maxindel=3 bwr=0.16 bw=12 minhits=2\
	quickmatch fast \
	path=$HOSTPATH ow=t;

# Step 7: QC contaminant removed sequences
bbduk.sh in="$F"_unmapped.s6.out.fastq \
	out="$F"_R1.s7.out.fastq out2="$F"_R2.s7.out.fastq outs="$F"_singletons.s7.out.fastq \
	qtrim=r trimq=30 \
	maxns=2 minlength=50 \
	ow=t;

# Step 8: Merge read pairs
bbmerge.sh in1="$F"_R1.s7.out.fastq in2="$F"_R2.s7.out.fastq \
	out="$F"_merged.fastq outu1="$F"_R1.unmerged.fastq outu2="$F"_R2.unmerged.fastq \
	rem k=62 extend2=50 ecct vstrict=t \
	-Xmx128g \
	ow=t;

# Step 9: Read repair
	grep -A 3 '1:N:' "$F"_singletons.s7.out.fastq | sed '/^--$/d' > "$F"_singletons_R1.out.fastq;
	grep -A	3 '2:N:' "$F"_singletons.s7.out.fastq | sed '/^--$/d' > "$F"_singletons_R2.out.fastq;

	cat "$F"_merged.fastq "$F"_R1.unmerged.fastq "$F"_singletons_R1.out.fastq > "$F"_R1.s8.out.fastq;
	cat "$F"_merged.fastq "$F"_R2.unmerged.fastq "$F"_singletons_R2.out.fastq > "$F"_R2.s8.out.fastq;
done
