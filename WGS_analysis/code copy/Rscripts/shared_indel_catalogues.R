### clustering Gene's 89-channel indel profiles ###

library(tidyverse)
library(indelsig.tools.lib)
library(umap)
library(ggrepel)
library(gridExtra)

# read in de novo files previously formatted for the indelsig package
id_dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_files_by_sample_indelsig/"
id_files <- list.files("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_files_by_sample_indelsig")

id_denovo_per_sample <- lapply(seq_along(id_files), function(x) {
  path <- paste0(id_dir, id_files[x])
  file <- read_delim(path, delim="\t")
})
names(id_denovo_per_sample) <- gsub("\\.txt$", "", id_files)

# read in shared indels
id_shared <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/ids_shared_sigprof.txt", delim="\t")
id_shared <- id_shared[, c(2, 6:10)]
id_shared_per_sample <- split(id_shared, id_shared$Sample)

### SHARED INDELS ###

# format to fit the indelsig package
id_shared_per_sample <- lapply(id_shared_per_sample, function(x) {
  x[, 4] <- NULL
  x <- x[, c(2:5, 1)]
  colnames(x) <- c("chr", "position", "REF", "ALT", "sample")
  return(x)
})

# indel segmentation
id_segmented <- lapply(id_shared_per_sample, function(sample) {
  seg <- indel_classifier89(sample, "hg38")
  return(seg)
})

# generating 89-channel catalogues
id_catalogues <- lapply(id_segmented, function(sample) {
  catalogue <- gen_catalogue89(sample, sample_col = 4)
  return(catalogue)
})

# plot 89-channel profiles of shared muts
p_all <- list()
for (i in seq_along(id_catalogues)) {
  muts_basis <- id_catalogues[[i]]
  sample_name <- names(id_catalogues)[i]
  # Assuming each muts_basis is a data frame with one column
  p <- gen_plot_catalouge89_single(
    data.frame(Sample = muts_basis[, 1], IndelType = rownames(muts_basis)),
    3,
    sample_name
  )
  p_all[[i]] <- p
}

print(p_all)

pdf(file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/indelsig.tools.lib/all_samples_shared_indel_catalogues.pdf", width = 40, height = 15)
do.call("grid.arrange", c(p_all, ncol = 6, nrow = 4))
dev.off()
