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

# 4. Filter potential edits in the VCF file
SOWMYA EDIT THIS
````
