# Base editing off-target RNA detection

Aryee/Joung lab processing code for identifying off-target base editing in RNA-seq data.


### Execution order
```
# 1. Go from .fastq to AR (analysis ready) .bam files using GATK best practices
GATK-fastq-ARbam-hg38.sh

# 2. Estimate Per-library nucleotide abudances per position
bam-readcount-CL.sh

# 3. Create a .vcf of potential edits based on HaplotypeCaller
haplotypeCaller.sh

# 4. Match edits in the VCF file with corresponding read counts
step2.sh
Usage: step2.sh
        --vcf_control=control_vcf_file
        --readcounts_control=control_bam_readcounts_gz
        --vcf_treated=treated_vcf_file
        --readcounts_treated=treated_bam_readcounts_gz
        
# 5. Call step3.R with output from step4.
Rscript step3.R VCF_TREATED.sorted.vcf_with_coverage.be_and_control.txt 
The code was run on R version 3.5.1
````

### Exome

Within `code`, there is also the `GATK_exome.sh` file, which is the workflow for genotyping and analyzing the whole-exome sequencing data associated with this work. 

<br><br>
