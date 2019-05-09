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


 step2.sh
Usage: step2.sh
        --vcf_control=control_vcf_file
        --readcounts_control=control_bam_readcounts_gz
        --vcf_tFilterSOWMYAreated=treated_vcf_file
        --readcounts_treated=treated_bam_readcounts_gz
        
This internally calls step3.R. 
The code was run on R version 3.5.1
````
