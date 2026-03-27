# a script to generate clean tables with all mutations from WGS 30x, batch1 and 2
# removing CRISPR2-A6

library(reshape2)
library(tidyverse)
library(data.table)
library(magrittr)

# # reading in the data - MAIN
# snv1 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/caveman.txt", sep = "\t", header = T)
# head(snv1)
# snv2 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/substitutions/caveman_may25.txt", sep = "\t", header = T)
# head(snv2)

### SNV ###
# reading in data - DE NOVO
snv1 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/denovo_snv.txt", sep = "\t", header = T)
snv2 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/substitutions/substitution_denovo_may25.txt", sep = "\t", header = T)

# cleaning snv1
# simplify the sample names
snv1$Sample <- sapply(snv1$Sample, function(x) sub("_vs_HCEC-MC", "", x))
head(snv1$Sample)
# remove unsuccessful CRISPR2 KOs from the subs table 
snv1 <- snv1[!(snv1$Sample %in% c("A6-1", "A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
print(unique(snv1$Sample)) # check if it worked
# fix the order of samples
sample_order <- c("HC1", "HC2", "MLH1-A6-PC", "A2-1", "A2-2", "C1-1", "F7-1", "C12-1", "C12-2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2", "D6B")
snv1_ordered <- snv1[order(match(snv1$Sample, sample_order)), ]
head(snv1_ordered)
# adding a column with KO labels
KOlist <- c("WT", "WT", "MLH1-/- (PC)", "MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "MLH1-/- MSH6-/- (sim)")
sample_to_KO <- setNames(KOlist, sample_order)
print(sample_to_KO)
snv1_ordered$KO <- sample_to_KO[as.character(snv1_ordered$Sample)]

# cleaning snv2
# simplify the sample names
snv2$Sample <- sapply(snv2$Sample, function(x) {sub("_vs_HCEC-MC", "", x)})
head(snv2$Sample)
print(unique(snv2$Sample)) # check the order of samples
snv2 <- snv2[snv2$Sample %in% c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")] # retaining only the CRISPR2-A2 samples
head(snv2$Sample)
# adding a column with KO labels
sample_order2 <- c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
KOlist2 <- c("MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-")
sample_to_KO2 <- setNames(KOlist2, sample_order2)
print(sample_to_KO2)
snv2$KO <- sample_to_KO2[as.character(snv2$Sample)]

# combining the two dfs
snv1_ordered$mut_ID <- NULL
snv_merged <- rbind(snv1_ordered, snv2)
print(unique(snv_merged$Sample))
# move D6B to after C7_1
sample_order_final <- c("HC1", "HC2", "MLH1-A6-PC", "A2-1", "A2-2", "C1-1", "F7-1", "C12-1", "C12-2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2", "C10_1", "C7_1", "D6B", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
snv_merged_final <- snv_merged[order(match(snv_merged$Sample, sample_order_final)), ]
print(unique(snv_merged_final$Sample))

# save as txt file
write.table(snv_merged_final, file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", row.names = FALSE, quote = FALSE)
# checking which columns of the data frame are lists
# sapply(snv_merged_final, is.list)

### INDELS ###

id1 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/denovo_indel_19094_new.txt.zip", sep = "\t", header = T)
head(id1)
id2 <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/indels/indels_denovo_may25.txt", sep = "\t", header = T)
head(id2)

# cleaning id1 
# remove unsuccessful CRISPR2 KOs
id1 <- id1[!(id1$Sample %in% c("A6-1", "A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
print(unique(id1$Sample)) # check if it worked
# fix the order of samples
sample_order <- c("HC1", "HC2", "MLH1-A6-PC", "A2-1", "A2-2", "C1-1", "F7-1", "C12-1", "C12-2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2", "D6B")
id1_ordered <- id1[order(match(id1$Sample, sample_order)), ]
head(id1_ordered)
# clean up columns
id1_ordered <- id1_ordered[, 1:12] %>% 
  select(chr, everything()) %>% 
  rename(CHROM = chr, POS = position)

# cleaning id2
id2 <- id2[id2$Sample %in% c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")] # retaining only the CRISPR2-A2 samples
head(id2$Sample)
id2_ordered <- id2[, 1:12] %>% 
  select(chr, everything()) %>% 
  rename(CHROM = chr, POS = position)

# ordering samples
sample_order_2 <- c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
id2_ordered <- id2_ordered[order(match(id2_ordered$Sample, sample_order_2)), ]

# merging both dfs
id_merged <- rbind(id1_ordered, id2_ordered)
print(unique(id_merged$Sample))
# move D6B to after C7_1
sample_order_final <- c("HC1", "HC2", "MLH1-A6-PC", "A2-1", "A2-2", "C1-1", "F7-1", "C12-1", "C12-2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2", "C10_1", "C7_1", "D6B", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
id_merged_final <- id_merged[order(match(id_merged$Sample, sample_order_final)), ]
print(unique(id_merged_final$Sample))
# add KO column
KO_combined <- c("WT", "WT", "MLH1-/- (PC)", "MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/- (sim)", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-")
sample_to_KO_id <- setNames(KO_combined, sample_order_final)
print(sample_to_KO_id)
id_merged_final$KO <- sample_to_KO_id[as.character(id_merged_final$Sample)]

# save as a txt file
write.table(id_merged_final, file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", row.names = FALSE, quote = FALSE)

