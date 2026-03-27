# script to calculate VAFs from Strelka2 indel VCF files
# looping through all the samples

library(VariantAnnotation)
library(ggplot2)

# sample list
samSheet <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv")
samList <- samSheet$sample_id
# samList <- subset(samSheet$sample_id, !(samSheet$sample_id %in% c("HC1", "HC2")))

# list of file paths to id_filtered files for all samples
dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/"
pathList <- lapply(samList, function(sample) {
  paste0(dir, sample, "/somatic.indels.filtered.vcf.gz")
})
print(pathList)

# list of vcf files
vcfList <- lapply(pathList, function(sample) {
  readVcf(sample, "hg38")
})
summary(vcfList)

# extracting the read counts and bases from the vcf files
# the same functions as in strelka_snvs_vaf_Akanksha but inside lapply
VAF_list <- list()
VAF_list <- lapply(vcfList, function(vcf_file) {
  
  dataframe_dp <- vcf_file@assays@data@listData
  TAR <- dataframe_dp$TAR[,2,1]
  TIR <- dataframe_dp$TIR[,2,1]
  
  VAFvector <- numeric(length(TIR))
  VAFvector <- unlist(lapply(seq_along(TIR), function(a) {
    ifelse(TIR[[a]] == 0, 0, TIR[[a]] / (TIR[[a]] + TAR[[a]]))
  }))
  
  # # Filter out VAF values where VAF = 0
  # VAFnonzero <- VAFvector[VAFvector != 0]
  # 
  return(VAFvector)
})

# Plot histogram of non-zero VAF values
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/vaf_indels_filtered.pdf")

plots <- lapply(seq_along(VAF_list), function(i) {
  sample <- samList[i]
  VAF <- VAF_list[[i]]
  
  p <- ggplot() +
    geom_histogram(aes(x = VAF), bins = 100) +
    labs(title = sample, x = "VAF", y = "count") +
    theme_light()
  
  print(p)
})

dev.off()