### FINAL PANELS OF SBS AND INDEL PROFILES ###
# TO BE INCLUDED IN THESIS APPENDIX #

library(tidyverse)
library(data.table)
library(signature.tools.lib)
library(indelsig.tools.lib)
library(gridExtra)

# data
sbs_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)
id_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)
sbs_shared <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/sbs_shared_sigprof.txt", sep = "\t", header = T)
id_shared <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/ids_shared_sigprof.txt", sep = "\t", header = T)

### CREATE AND PLOT SBS CATALOGUES ###
# formatting the input files to fit in the signature.tools.lib package
sbs_denovo <- sbs_denovo[ , c(1:2, 4:5, 12:13)]
colnames(sbs_denovo) <- c("chr", "position", "REF", "ALT", "sample", "genotype")
sbs_shared <- sbs_shared[ , c(2, 6:7, 9:10)]
sbs_shared <- sbs_shared[ , c(2:5, 1)]
colnames(sbs_shared) <- c("chr", "position", "REF", "ALT", "sample")
lookup <- unique(sbs_denovo[, c("sample", "genotype")])
sbs_shared$genotype <- lookup$genotype[match(sbs_shared$sample, lookup$sample)]
sbs_shared$sample <- paste0(sbs_shared$sample, "_shared") #modifying sample names to merge two dfs

# extracting sample names
samples_denovo <- unique(sbs_denovo$sample)
samples_shared <- unique(sbs_shared$sample)
samples_combined <- c(rbind(samples_denovo, samples_shared)) # interleave two vectors

# merge two dfs
sbs_combined <- rbind(sbs_denovo, sbs_shared)

# order the merged df - shared muts follow de novo muts for each sample
sbs_combined$sample <- factor(sbs_combined$sample, levels = samples_combined)
sbs_combined <- sbs_combined[order(sbs_combined$sample), ]

# calculate SBS catalogues
sbs_combined_by_sample <- split(sbs_combined, sbs_combined$sample)
sbs_cat <- lapply(sbs_combined_by_sample, function(x) {
  tabToSNVcatalogue(x, genome.v = "hg38")
})

## example code from the package's documentation
#load SNV data and convert to SNV mutational catalogues
SNVcat_list <- list()
for (i in 1:length(sbs_combined_by_sample)){
  res <- tabToSNVcatalogue(subs = sbs_combined_by_sample[[i]], genome.v = "hg38")
  colnames(res$catalogue) <- samples_combined[i]
  SNVcat_list[[i]] <- res$catalogue
}
#bind the catalogues in one table
SNV_catalogues <- do.call(cbind,SNVcat_list)

# merge catalogues into one d
# plot 96-channel SBS profiles
p_all_subs <- plotSubsSignatures(signature_data_matrix = SNV_catalogues,
                                output_file = "temp_plot.pdf",
                                plot_sum = TRUE,
                                overall_title = "96-channel profiles of de novo and shared SBS",
                                add_to_titles = NULL,
                                mar = NULL,
                                howManyInOnePage = 24,
                                ncolumns = 2,
                                textscaling = 1)
### I can't get this function to return a plot instead of a NULL - abandoned and moved on to CRISPR1 indels


