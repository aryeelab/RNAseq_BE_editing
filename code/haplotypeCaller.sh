#!/bin/bash

sample=$1

tempjava="/PATH/TO/java-tmp"
gatkjar="/PATH/TO/GenomeAnalysisTK.jar"

threads="16"
maxJavaMem="128000m"

fasta="/PATH/TO/base_editing/hg38/hg38.fa"


java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -nct $threads -T HaplotypeCaller -R $fasta -I "forVariantCalling/${sample}.bam" -o "variantCalls/gatk3.8-erisone/${sample}.vcf" -dontUseSoftClippedBases -stand_call_conf 20.0



