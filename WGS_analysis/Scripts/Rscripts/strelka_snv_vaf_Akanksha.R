# script to calculate VAFs from Strelka2 SNV VCF files

library(VariantAnnotation)
library(ggplot2)

vcf_snv_path <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_180724/A2-1/somatic.snvs.filtered.vcf.gz"
vcf_snv <- readVcf(vcf_snv_path, "hg38")
vcf_snv_unflt_path <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_180724/A2-1/somatic.snvs.vcf.gz"
vcf_snv_unflt <- readVcf(vcf_snv_unflt_path, "hg38")

# extracting base and count values from the VCF file
ref <- matrix(ref(vcf_snv))
alt <- matrix(unlist(alt(vcf_snv)))

dataframe_dp <- vcf_snv@assays@data@listData
au <- dataframe_dp$AU[,,1][,1]
cu <- dataframe_dp$CU[,,1][,1]
gu <- dataframe_dp$GU[,,1][,1]
tu <- dataframe_dp$TU[,,1][,1]

# getting the read counts for the reference allele
# # LOOP VERSION - slower
# refCounts <- c()
# counter = 1
# 
# for (i in ref) {
#   if (i == "A") {
#     refCounts <- append(refCounts, au[counter])
#   } else if (i == "C") {
#       refCounts <- append(refCounts, cu[counter])
#   } else if (i == "G") {
#       refCounts <- append(refCounts, gu[counter])
#   } else if (i == "T") {
#       refCounts <- append(refCounts, tu[counter])
#   } else {next}
#   counter = counter + 1
# }

# LAPPLY VERSION - faster
# from ChatGPT
# Create a list of vectors corresponding to each nucleotide
nucleotide_counts <- list(
  "A" = au,
  "C" = cu,
  "G" = gu,
  "T" = tu
)

# Initialize refCounts vector
refCounts <- numeric(length(ref))
# Use lapply to assign counts based on ref
refCounts <- unlist(lapply(seq_along(ref), function(i) {
  ifelse(ref[i] %in% names(nucleotide_counts), nucleotide_counts[[ref[i]]][i], NA)
}))
# Filter out NA values (optional, if you want to exclude entries where ref is not A, C, G, or T)
refCounts <- refCounts[!is.na(refCounts)]

# # getting the read counts for the alternate allele
# altCounts <- c()
# counter = 1
# 
# for (i in alt) {
#   if (i == "A") {
#     altCounts <- append(altCounts, au[counter])
#   } else if (i == "C") {
#     altCounts <- append(altCounts, cu[counter])
#   } else if (i == "G") {
#     altCounts <- append(altCounts, gu[counter])
#   } else if (i == "T") {
#     altCounts <- append(altCounts, tu[counter])
#   } else {next}
#   counter = counter + 1
# }

# LAPPLY version 
# Initialize refCounts vector
altCounts <- numeric(length(alt))
# Use lapply to assign counts based on ref
altCounts <- unlist(lapply(seq_along(alt), function(i) {
  ifelse(ref[i] %in% names(nucleotide_counts), nucleotide_counts[[alt[i]]][i], NA)
}))
# Filter out NA values (optional, if you want to exclude entries where ref is not A, C, G, or T)
altCounts <- altCounts[!is.na(altCounts)]

# # calculating VAF
# VAFvector <- c()
# 
# for (a in seq_along(refCounts)) {
#   if (altCounts[[a]] == 0) {
#     VAFvector <- append(VAFvector, 0)
#   } else {
#     VAF <- altCounts[[a]]/(altCounts[[a]]+refCounts[[a]])
#     VAFvector <- append(VAFvector, VAF)
#   }
# }

# LAPPLY version
VAFvector <- numeric(length(altCounts))
VAFvector <- unlist(lapply(seq_along(refCounts), function(a) {
  ifelse(altCounts[[a]]==0, 0, altCounts[[a]]/(altCounts[[a]]+refCounts[[a]]))
}))

# lots of alternate alleles have read counts = 0
# exclude these for the clarity of plotting
VAFnonzero <- VAFvector[VAFvector != 0]

p <- ggplot() +
  geom_histogram(aes(x = VAF2nonzero), bins=100) +
  labs(x = "VAF", y = "count") +
  theme_light()
print(p)