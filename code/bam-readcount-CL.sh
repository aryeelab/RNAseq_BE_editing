#!/bin/bash

# Get sample name from user input
sample=$1

fasta="/data/aryee/caleb/joung/base_editing/hg38/hg38.fa"

mkdir -p bam-readcount
/apps/lab/aryee/bam-readcount/bin/bam-readcount -w 1 -f $fasta "forVariantCalling/${sample}.bam"  | sed 's/:/\t/g' | awk 'BEGIN{print "CHR\tBP\tREF\tTOTAL\tA\tC\tG\tT\tN"}; {print $1,$2,$3,$4,$20,$34,$48,$62,$76}' OFS='\t' | gzip > "bam-readcount/${sample}.all_positions.txt.gz" 


