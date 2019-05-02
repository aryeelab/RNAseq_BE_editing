#!/bin/bash

sample=$1

tempjava="/data/aryee/caleb/joung/base_editing/java-tmp"
gatkjar="/data/aryee/caleb/joung/base_editing/jars/GenomeAnalysisTK.jar"

threads="16"
maxJavaMem="128000m"

fasta="/data/aryee/caleb/joung/base_editing/hg38/hg38.fa"


java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -nct $threads -T HaplotypeCaller -R $fasta -I "forVariantCalling/${sample}.bam" -o "variantCalls/gatk3.8-erisone/${sample}.vcf" -dontUseSoftClippedBases -stand_call_conf 20.0



