# script to extract shared and private indels between subclones
# each subclone gets compared its sibling subclone 

library(VariantAnnotation)
library(ggplot2)
library(dplyr)
library(purrr)

# sample list
samList_full <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv")
samList <- unique(samList_full[, 1:3])
samList[,2] <- paste0(samList$clone, samList$subclone)

# clone_idx <- seq(2, length(samList_full$clone), by = 2)
# clone_list <- samList_full$clone[clone_idx]
# samList[,3] <- cbind(clone_list)
# names(samList)[3] <- "parent"

# selecting samples to analyse
# subclones <- subset(samList, parent %in% c("C8"))
# subclones <- subclones[3:4,]

# subclones <- subset(samList, genotype %in% c("MLH1_MBD4_KO"))
subclones <- c("C1-2", "F7-1")

# list of vcf file paths to import
dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/"
pathList <- lapply(subclones, function(sample) {
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

# converting variant lists into data frames
variants <- lapply(variants, function(sample) {
  as.data.frame(sample)
})

# saving each sample as a separate df
# to check the variants manually
# C8A <- as.data.frame(variants[[1]])
# C8B <- as.data.frame(variants[[2]])

# finding shared variants
shared_variants <- reduce(variants, inner_join)

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
# C8Avaf <- t(as.data.frame(shared_VAF[[3]]))
# C8Bvaf <- t(as.data.frame(shared_VAF[[4]]))

# creating a final data frame withh variants and their VAFs
shared_VAF_combined <- as.data.frame(cbind(C1.2vaf, F7.1vaf))
col_names <- subclones
shared_VAF_combined <- setNames(shared_VAF_combined, col_names)
final_df <- cbind(shared_variants, shared_VAF_combined)
rownames(final_df) <- seq_along(1:127)

write.csv(final_df, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_indels_per_clone/C1.2.F7.1_shared_variants.csv")

