if [[ $# -lt 4 ]]; then
    echo "Usage: `basename $0`
        --vcf_control=control_vcf_file
        --readcounts_control=control_bam_readcounts_gz
        --vcf_treated=treated_vcf_file
        --readcounts_treated=treated_bam_readcounts_gz
         ">&2
    exit 1
fi


for i in "$@"
do
case $i in
    --vcf_control=*)    
    VCF_CONTROL="${i#*=}"
    shift
    ;;
    --readcounts_control=*)    
    READCOUNTS_CONTROL_GZIP="${i#*=}"
    shift
    ;;
    --vcf_treated=*)    
    VCF_TREATED="${i#*=}"
    shift
    ;;
    --readcounts_treated=*)    
    READCOUNTS_TREATED_GZIP="${i#*=}"
    shift
    ;;
   -h)
	echo "Usage: `basename $0`
        --vcf_control=control_vcf_file
        --readcounts_control=control_bam_readcounts_gz
        --vcf_treated=treated_vcf_file
        --readcounts_treated=treated_bam_readcounts_gz
        ">&2
    exit 1
    shift
    ;;
    *)
    ;;
esac
done

READCOUNTS_CONTROL=`echo ${READCOUNTS_CONTROL_GZIP} | sed 's/\.gz//g'`
READCOUNTS_TREATED=`echo ${READCOUNTS_TREATED_GZIP} | sed 's/\.gz//g'`
#zcat ${READCOUNTS_CONTROL_GZIP} > ${READCOUNTS_CONTROL}
#zcat ${READCOUNTS_TREATED_GZIP} > ${READCOUNTS_TREATED}

# Sort files to be joined for control. Join is done by position key chr_position, which is first column
LC_ALL=C zcat ${READCOUNTS_CONTROL_GZIP} | awk '{ print $1"_"$2"\t"$0}'  | sort -k1,1 > ${READCOUNTS_CONTROL}.sorted
LC_ALL=C awk '{print $1"_"$2"\t"$0}' ${VCF_CONTROL} | sort -k1,1 >  ${VCF_CONTROL}.sorted 
join ${VCF_CONTROL}.sorted ${READCOUNTS_CONTROL}.sorted -1 1 -2 1 | sed 's/ /\t/g' | cut -f1-7,14-21 > ${VCF_CONTROL}.sorted.vcf_with_coverage.txt 

# Sort files to be joined for treated. Join is done by position key chr_position, which is first column
LC_ALL=C zcat ${READCOUNTS_TREATED_GZIP} | awk '{print $1"_"$2"\t"$0}' | sort -k1,1 > ${READCOUNTS_TREATED}.sorted 
LC_ALL=C awk '{print $1"_"$2"\t"$0}' ${VCF_TREATED} | sort -k1,1 > ${VCF_TREATED}.sorted 
join ${VCF_TREATED}.sorted ${READCOUNTS_TREATED}.sorted -1 1 -2 1 | sed 's/ /\t/g' | cut -f1-7,14-21  > ${VCF_TREATED}.sorted.vcf_with_coverage.txt 

# Join treated vcf B (that now has treated bam-readcounts)  with control bam read counts. Fill with 0 for entries where the treated vcf does not have a corresponding entry in control bam-readcounts
join ${VCF_TREATED}.sorted.vcf_with_coverage.txt ${READCOUNTS_CONTROL}.sorted -1 1 -2 1 -a 1 | sed 's/ /\t/g' | awk '{ if (NF == 14) {print $0"\t0\t0\t0\t0\t0\t0\t0\t0\t0"} else {print $0}}' > ${VCF_TREATED}.sorted.vcf_with_coverage.be_and_control.txt

#Rscript step3.R ${VCF_TREATED}.sorted.vcf_with_coverage.be_and_control.txt
