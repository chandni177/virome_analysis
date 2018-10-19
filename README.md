# Virome Analysis Scripts and Workflows

Scripts and Workflows Useful for Virome Analysis


# Sequence Decontamination

8 Step procedure contained in /scripts/conaminant_removal.sh

* Step 1: Remove leftmost primerB. Not the reverse complements
* Step 2: Remove read through. Reverse complement of primerB + 6 bases of the adapter
* Step 3: Remove additional (primer free) adapter contamination
* Step 4: Remove any remaining sequence which contains any primer in either orientation
* Step 5: PhiX Removal
* Step 6: Host-removal
* Step 7: QC contaminant removed sequences
* Step 8: Read merge
* Step 9: Read 1 repair

![alt text](https://github.com/shandley/virome_analysis/blob/master/sequence_decontamination.png)

