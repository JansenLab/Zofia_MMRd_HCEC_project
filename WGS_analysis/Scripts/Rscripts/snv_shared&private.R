# script to extract shared and private SNVs between subclones
# each subclone gets compared its sibling subclone 

library(VariantAnnotation)
library(ggplot2)
library(dplyr)
library(purrr)

subclones <- c("C1-2", "F7-1")

# list of vcf file paths to import
dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/"
pathList <- lapply(subclones, function(sample) {
  paste0(dir, sample, "/somatic.snvs.filtered.vcf.gz")
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

# converting variant lists into data frames
variants <- lapply(variants, function(sample) {
  as.data.frame(sample)
})

# saving each sample as a separate df
# to check the variants manually
# F7.1 <- as.data.frame(variants[[1]])
# F7.2 <- as.data.frame(variants[[2]])
# B8A <- as.data.frame(variants[[3]])
# B8B <- as.data.frame(variants[[4]])

# finding shared variants
shared_variants <- reduce(variants, inner_join)
# all the retrieved variants are present in all samples (have checked manually)

# calculating variant VAF 
# to check if shared variants are clonal
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
  
  return(VAFvector)
})

# extracting row numbers of shared variants in each sample
row_numbers <- lapply(seq_along(variants), function(sample){
  
  rowList <- lapply(1:nrow(shared_variants), function(variant) {

    chr <- shared_variants$chr[[variant]]
    pos <- shared_variants$pos[[variant]]
    ref <- shared_variants$ref[[variant]]
    alt <- shared_variants$alt[[variant]]

    row <- which(variants[[sample]]$chr == chr &
                   variants[[sample]]$pos == pos &
                   variants[[sample]]$ref == ref &
                   variants[[sample]]$alt == alt)

    return(row)
  })
  return(rowList)
})

# matching row numbers of shared variants in each sample to their VAFs in that sample
shared_VAF <- lapply(seq_along(row_numbers), function(sample) {
  
  VAF_vector <- lapply(1:length(row_numbers[[1]]), function(i) {
    index <- row_numbers[[sample]][[i]]
    VAF <- VAF_list[[sample]][[index]]
  
    return(VAF)
  })
  return(VAF_vector)
})

C1.2vaf <- t(as.data.frame(shared_VAF[[1]]))
F7.1vaf <- t(as.data.frame(shared_VAF[[2]]))
# A6.1vaf <- t(as.data.frame(shared_VAF[[3]]))
# A6.2vaf <- t(as.data.frame(shared_VAF[[4]]))

shared_VAF_combined <- as.data.frame(cbind(C1.2vaf, F7.1vaf))
col_names <- subclones
shared_VAF_combined <- setNames(shared_VAF_combined, col_names)
final_df <- cbind(shared_variants, shared_VAF_combined)
rownames(final_df) <- seq_along(1:222)

write.csv(final_df, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_snvs_per_clone/C1.2.F7.1_shared_variants.csv")

### DISUSED CODE WASTELAND ###

# shared_variants <- all_variants %>%
#   # group_by("chr", "pos", "ref", "alt") %>%
#   filter(n_distinct(source) == 4) %>%
#   # ungroup() %>%
#   select(-source) %>%
#   distinct()
# this code doesn't work

# # combining variants from all samples into one df
# all_variants <- bind_rows(
#   variants[[1]] %>% mutate(source = "A2-1"),
#   variants[[2]] %>% mutate(source = "A2-2"),
#   variants[[3]] %>% mutate(source = "A6-1"),
#   variants[[4]] %>% mutate(source = "A6-2")
# )
