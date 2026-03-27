# script to calculate VAFs from Strelka2 SNV VCF files
# looping through all the samples

library(VariantAnnotation)
library(ggplot2)

# sample list
samSheet <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv")
samList <- samSheet$sample_id
# samList <- subset(samSheet$sample_id, !(samSheet$sample_id %in% c("HC1", "HC2")))

# list of file paths to snv_filtered files for all samples
dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/"
pathList <- lapply(samList, function(sample) {
  paste0(dir, sample, "/somatic.snvs.filtered.vcf.gz")
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
  
  ref <- matrix(ref(vcf_file))
  alt <- matrix(unlist(alt(vcf_file)))
  
  dataframe_dp <- vcf_file@assays@data@listData
  au <- dataframe_dp$AU[,2,1]
  cu <- dataframe_dp$CU[,2,1]
  gu <- dataframe_dp$GU[,2,1]
  tu <- dataframe_dp$TU[,2,1]
  
  nucleotide_counts <- list(
    "A" = au,
    "C" = cu,
    "G" = gu,
    "T" = tu
  )
  
  refCounts <- numeric(length(ref))
  refCounts <- unlist(lapply(seq_along(ref), function(i) {
    ifelse(ref[i] %in% names(nucleotide_counts), nucleotide_counts[[ref[i]]][i], NA)
  }))
  refCounts <- refCounts[!is.na(refCounts)]
  
  altCounts <- numeric(length(alt))
  altCounts <- unlist(lapply(seq_along(alt), function(i) {
    ifelse(alt[i] %in% names(nucleotide_counts), nucleotide_counts[[alt[i]]][i], NA)
  }))
  altCounts <- altCounts[!is.na(altCounts)]
  
  VAFvector <- numeric(length(altCounts))
  VAFvector <- unlist(lapply(seq_along(refCounts), function(a) {
    ifelse(altCounts[[a]] == 0, 0, altCounts[[a]] / (altCounts[[a]] + refCounts[[a]]))
  }))
  
  # Filter out VAF values where VAF = 0
  # VAF2nonzero <- VAFvector[VAFvector != 0]
  
  return(VAFvector)
})

# Plot histogram of non-zero VAF values
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/vaf_snv_filtered.pdf")

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