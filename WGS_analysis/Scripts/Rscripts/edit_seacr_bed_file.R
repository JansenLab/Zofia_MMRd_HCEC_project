### editing a seacr.peaks.stringent.bed for SPT ###

library(tidyverse)
library(data.table)

file <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/h3k36me3_hc2_R1.seacr.peaks.stringent.bed", sep = "\t", header = F) 

## file version 1
# insert additional columns
file <- cbind(file, ".")
file <- cbind(file, ".")
file <- cbind(file, ".")

# move the new columns to the correct position
names(file) <- make.unique(names(file)) # relocate requires unique column names
file <- file %>%
  relocate(7:9, .after = 3)

# remove the last column
file[, 9] <- NULL

# add two more at the end
file <- cbind(file, ".")
file <- cbind(file, ".")

write_tsv(file, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/h3k36me3_hc2_R1.seacr.peaks.stringent.V1.bed")

## version 2
file2 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/h3k36me3_hc2_R1.seacr.peaks.stringent.bed", sep = "\t", header = F) 
file2[, 6] <- NULL

write_tsv(file, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/h3k36me3_hc2_R1.seacr.peaks.stringent.V2.bed")
