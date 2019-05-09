library(readr)
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(tidyr)
library(tibble)

vcf_with_coverage_file <- commandArgs(TRUE)[1]

bamreadcounts_treated_vs_control <- read_tsv(vcf_with_coverage_file, 
                                                 col_names = c("poskey", "chr", "POS", "other", "REF","ALT", "QUAL", "ref.other", "total_reads.treated", "A.treated", "C.treated", "G.treated","T.treated","N.treated", "chr_other", "pos_other","ref_other_2","total_reads.control", "A.control", "C.control", "G.control","T.control","N.control"))
    
  
    threshold_treated <- quantile(bamreadcounts_treated_vs_control$total_reads.treated, 0.90)
    cat("treated vs control: 90th percentile threshold = " , threshold_treated,"\n")
  
    bamreadcounts_treated_vs_control %>% 
      filter(total_reads.control > threshold_treated  & 
               nchar(REF) == 1 & 
               nchar(ALT) == 1) %>% 
      mutate("snv" = paste0(REF,"_",ALT),
             "frac_ref_in_control" = case_when(REF == "C" ~ C.control/total_reads.control, 
                                               REF == "G" ~ G.control/total_reads.control,
                                               REF == "A" ~ A.control/total_reads.control,
                                               REF == "T" ~ T.control/total_reads.control,
                                               TRUE ~ 0),
             "frac_ref_in_beOverexp" = case_when(REF == "C" ~ C.treated/total_reads.treated, 
                                                 REF == "G" ~ G.treated/total_reads.treated,
                                                 REF == "A" ~ A.treated/total_reads.treated,
                                                 REF == "T" ~ T.treated/total_reads.treated,
                                                 TRUE ~ 0),
             "frac_alt_in_beOverexp" = case_when(ALT == "C" ~ C.treated/total_reads.treated, 
                                                 ALT == "G" ~ G.treated/total_reads.treated,
                                                 ALT == "A" ~ A.treated/total_reads.treated,
                                                 ALT == "T" ~ T.treated/total_reads.treated,
                                                 TRUE ~ 0)) %>%
      filter(frac_ref_in_control > 0.99) -> bamreadcounts_treated_vs_control_manhattan
    
    write_tsv(dplyr::count(bamreadcounts_treated_vs_control_manhattan, snv), path=paste0(basename(vcf_with_coverage_file),".treated_vs_control_snps.txt" ))
    
    write_tsv(bamreadcounts_treated_vs_control_manhattan, path=paste0(basename(vcf_with_coverage_file), ".all_snvs.stringent.txt" ))
    
    write_tsv(bamreadcounts_treated_vs_control_manhattan %>% 
                mutate("start"=POS, "end"=POS) %>%
                mutate(start = as.character(as.numeric(start)-1)) %>%
                select(chr, start, end, snv) %>% 
                arrange(chr, start), path=paste0(basename(vcf_with_coverage_file),"_variants_stringent.bed"), col_names = F)
