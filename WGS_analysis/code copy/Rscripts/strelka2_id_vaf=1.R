# script to calculate VAFs from Strelka2 SNV VCF files
# looping through all the samples

library(VariantAnnotation)
library(ggplot2)
library(dplyr)
library(purrr)

# sample list
samSheet <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv")
samList <- samSheet$sample_id
samList <- subset(samSheet$sample_id, !(samSheet$sample_id %in% c("HCEC-MC", "MLH1-A6-PC")))

# list of file paths to snv_filtered files for all samples
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

# extracting variants from all samples
variants <- lapply(vcfList, function(vcf_file) {
  
  chr <- as.character(seqnames(vcf_file))
  pos <- start(ranges(vcf_file))
  ref <- matrix(ref(vcf_file))
  alt <- matrix(unlist(alt(vcf_file)))
  
  # adding all extracted information to the list
  list(
    chr = chr,
    pos = pos,
    ref = ref,
    alt = alt
  )
})

# calculating variant VAF
VAF_list <- lapply(vcfList, function(vcf_file) {
  
  dataframe_dp <- vcf_file@assays@data@listData
  TAR <- dataframe_dp$TAR[,2,1]
  TIR <- dataframe_dp$TIR[,2,1]
  
  VAFvector <- numeric(length(TIR))
  VAFvector <- unlist(lapply(seq_along(TIR), function(a) {
    ifelse(TIR[[a]] == 0, 0, TIR[[a]] / (TIR[[a]] + TAR[[a]]))
  }))
  return(VAFvector)
})

# converting the variants and VAF lists into data frames
variants_df <- lapply(variants, as.data.frame)
VAF_df <- lapply(VAF_list, as.data.frame)

# merging the variants and VAF data frames
variants_full <- mapply(c, variants_df, VAF_df, SIMPLIFY = FALSE)
variants_full <- lapply(variants_full, as.data.frame)

# renaming the new added column as "VAF"
variants_full <- lapply(variants_full, function(df) {
  colnames(df)[5] <- "VAF"
  return(df)
 })

# naming list elements after samples
names(variants_full) <- samList

# filtering for variants with VAF = 1
variants_1 <- lapply(variants_full, function(sample) {
  sample <- sample[sample$VAF == 1, ]
  return(sample)
})

# saving variants with VAF=1 as csv files
lapply(seq_along(variants_1), function(i) {
  sample <- variants_1[[i]]
  sample_name <- names(variants_1)[i]
  write.csv(sample, paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/indels_vaf=1/", sample_name, ".csv"))
})

# shared variants between all samples
shared_variants <- reduce(variants_1, inner_join)
# works by finding variants where all 5 fields (chr, pos, ref, alt, VAF) are the same across all samples
# no such variants found
# there are variants with VAF = 1 shared between subclones 

# bar chart of chromosomes 
merged_df <- bind_rows(variants_1)

plot <- ggplot(data = merged_df) +
  geom_bar(aes(x = chr))

print(plot)
