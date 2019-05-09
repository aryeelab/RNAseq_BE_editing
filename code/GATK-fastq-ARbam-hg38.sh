#!/bin/bash

# Get sample name from user input
sample=$1

# Directory of fastq inputs -- assumed to be _1.fastq.gz and _2.fastq.gz in format
fqdir="combined"

# Paths to useful files / parameters
tempjava="/PATH/TO/java-tmp"
picardjar="/PATH/TO/picard.jar"
gatkjar="/PATH/TO/GenomeAnalysisTK.jar"
threads="16"
maxJavaMem="8000m"

# Parameters for alignment and GATK variant calling -- hg38
gtf="/PATH/TO/genes.gtf"
fasta="/PATH/TO/hg38.fa"
snpfile="/PATH/TO/dbsnp_138.hg38.vcf"
stardir="/PATH/TO/STAR_hg38"

# Make directories if they don't exist
mkdir -p aligned
mkdir -p temp
mkdir -p $tempjava
mkdir -p metrics
mkdir -p forVariantCalling

# Align with STAR and index
STAR --runMode alignReads \
    --readFilesCommand zcat \
    --outFilterMultimapNmax 1 \
    --outFilterScoreMinOverLread 0 \
    --outFilterMatchNminOverLread 0 \
    --quantMode GeneCounts \
    --twopassMode Basic \
    --outFileNamePrefix "aligned/${sample}" \
    --genomeDir $stardir  \
    --sjdbGTFfile $gtf \
    --runThreadN $threads \
    --readFilesIn "${fqdir}/${sample}_1.fastq.gz" "${fqdir}/${sample}_2.fastq.gz" \
    --outStd SAM | samtools view -buS - | samtools sort -@ $threads > "aligned/${sample}Aligned.sortedByCoord.out.bam"

samtools index "aligned/${sample}Aligned.sortedByCoord.out.bam"

# Add RG ID tags
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $picardjar AddOrReplaceReadGroups I="aligned/${sample}Aligned.sortedByCoord.out.bam" O="temp/${sample}.temp1.bam" SO=coordinate RGID=1 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=1

# Mark duplicates
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $picardjar MarkDuplicates INPUT="temp/${sample}.temp1.bam" OUTPUT="temp/${sample}.temp2.bam" METRICS_FILE="metrics/${sample}.rmdup.log" REMOVE_DUPLICATES=true ASSUME_SORTED=true VALIDATION_STRINGENCY=LENIENT
samtools index "temp/${sample}.temp2.bam"

# Adjust mapping quality
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -T SplitNCigarReads -R $fasta -I "temp/${sample}.temp2.bam" -o "temp/${sample}.temp3.bam" -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

# Variant quality recalibration
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -nct $threads -T BaseRecalibrator -R $fasta -I "temp/${sample}.temp3.bam" -o "metrics/${sample}.bqsr.out" -knownSites $snpfile
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -nct $threads -T BaseRecalibrator -R $fasta -I "temp/${sample}.temp3.bam" -BQSR "metrics/${sample}.bqsr.out" -o "metrics/${sample}.bqsr.postRecal.out" -knownSites $snpfile

# Ready now for haplotype caller -- print reads
java "-Xmx${maxJavaMem}" -Djava.io.tmpdir=$tempjava -jar $gatkjar -T PrintReads -R $fasta -I "temp/${sample}.temp3.bam" -BQSR "metrics/${sample}.bqsr.postRecal.out" -o "forVariantCalling/${sample}.bam"

# Send a single-threaded job off to perform bam-readcount on these samples 
bsub -q normal -o /dev/null sh bam-readcount-CL.sh $sample


