### extracting shared mutations for signature deconvolution using SigProfiler ###

library(tidyverse)
library(data.table)

# loading mutation data
subs_all <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_all_merged.txt", sep = "\t", header = T)
ids_all <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_all_merged.txt", sep = "\t", header = T)
subs_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)
ids_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)

# subtract de novo from all
sbs_shared <- setdiff(subs_all, subs_denovo)
ids_shared <- setdiff(ids_all, ids_denovo)

# write out the files
write_delim(sbs_shared, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/sbs_shared.txt", delim="\t")
write_delim(ids_shared, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/ids_shared.txt", delim="\t")

 ### format as input for SigProfiler ###

# read in the previous SG input for reference
snv_input_ref <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/input/denovo_snv_sigprofiler.txt", delim = "\t", col_names=TRUE)

### SBS
# delete unnecessary columns
sbs_shared[ , 6:11] = NULL
sbs_shared$KO = NULL

# add required columns
sbs_shared$Project <- "WGS_30x"
sbs_shared$ID <- "."
sbs_shared$Genome <- "GRCh38"
sbs_shared$mut_type <- "SNV"
sbs_shared$Type <- "SOMATIC"

# calculate end position
sbs_shared$pos_end <- sbs_shared$POS

# order columns
sbs_shared <- sbs_shared[, c(7, 6, 3, 8:9, 1, 2, 11, 4:5, 10)]
names <- c("Project", "Sample", "ID", "Genome", "mut_type", "chrom", "pos_start", "pos_end", "ref", "alt", "Type")
colnames(sbs_shared) <- names

### ID
# delete unnecessary columns
ids_shared[ , 6:11] = NULL
ids_shared$KO = NULL

# add required columns
ids_shared$Project <- "WGS_30x"
ids_shared$ID <- "."
ids_shared$Genome <- "GRCh38"
ids_shared$mut_type <- "ID"
ids_shared$Type <- "SOMATIC"

# calculate end position
ids_shared$pos_end <- ids_shared$POS
length_diff <- nchar(ids_shared$ALT) - nchar(ids_shared$REF)
is_indel <- ids_shared$REF != ids_shared$ALT
ids_shared$pos_end[is_indel] <- ids_shared$POS[is_indel] + abs(length_diff[is_indel])

# order columns
ids_shared <- ids_shared[, c(7, 6, 3, 8:9, 1, 2, 11, 4:5, 10)]
colnames(ids_shared) <- names

# write out files
write_delim(sbs_shared, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/sbs_shared_sigprof.txt", delim="\t")
write_delim(ids_shared, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/ids_shared_sigprof.txt", delim="\t")
