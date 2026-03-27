# checking if the de novo mutation counts from Gene match the simple filtering framework:
# 1. subtract MLH1-A6-PC variants (CRISPR1) / A2-1 and A2-2 variants (CRISPR2-A2)
# 2. subtract any variants shared by > 2 subclones
# 3. keep only mutations private to subclones

library(tidyverse)
library(data.table)

# read in the data
sbs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/substitutions/caveman_may25.txt", sep = "\t", header = T)
id <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/indels/combined_pindel_may25.tsv", sep = "\t", header = T)

# simplify the sample names
sbs$Sample <- sapply(sbs$Sample, function(x) sub("_vs_HCEC-MC", "", x))
id$Sample <- sapply(id$Sample, function(x) sub("_vs_HCEC-MC", "", x))

# remove CRISPR2-A6 samples
sbs <- sbs[!(sbs$Sample %in% c("A6-1", "A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
id <- id[!(id$Sample %in% c("A6-1", "A6-2", "A5A", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
samples <- unique(sbs$Sample)

# remove unneccessary columns
sbs <- sbs[ , c("CHROM", "POS", "REF", "ALT", "Sample")]
id <- id[ , c("CHROM", "POS", "REF", "ALT", "Sample")]

# calculate raw (unfiltered) variant counts
raw_sbs_counts <- sapply(samples, function(x) {
  count <- count(sbs[sbs$Sample == x, ])
})
raw_sbs_counts <- t(as.data.frame(raw_sbs_counts))
sbs_counts <- as.data.frame(cbind(raw_sbs_counts, samples))
colnames(sbs_counts) <- c("raw_count", "sample")

raw_id_counts <- sapply(samples, function(x) {
  count <- count(id[id$Sample == x, ])
})
raw_id_counts <- t(as.data.frame(raw_id_counts))
id_counts <- as.data.frame(cbind(raw_id_counts, samples))
colnames(id_counts) <- c("raw_count", "sample")

# split into CRISPR1 and CRISPR2
crispr1 <- c("HC1", "HC2", "A2-1", "A2-2", "C1-1", "F7-1", "C12-1", "C12-2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2", "D6B")
crispr2 <- c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
sbs1 <- sbs[sbs$Sample %in% crispr1, ]
sbs2 <- sbs[sbs$Sample %in% crispr2, ]
id1 <- id[id$Sample %in% crispr1, ]
id2 <- id[id$Sample %in% crispr2, ]

# construct background dfs
MLH1_A6_PC_sbs <- sbs[sbs$Sample == "MLH1-A6-PC", ]
A2_sbs <- sbs[sbs$Sample %in% c("A2-1", "A2-2"), ]

MLH1_A6_PC_id <- id[id$Sample == "MLH1-A6-PC", ]
A2_id <- sbs[sbs$Sample %in% c("A2-1", "A2-2"), ]

## FILTER 1 ##
sbs1 <- anti_join(sbs1, MLH1_A6_PC_sbs, by = c("CHROM", "POS", "REF", "ALT"))
id1 <- anti_join(id1, MLH1_A6_PC_id, by = c("CHROM", "POS", "REF", "ALT"))

sbs2 <- anti_join(sbs2, A2_sbs, by = c("CHROM", "POS", "REF", "ALT"))
id2 <- anti_join(id2, A2_id, by = c("CHROM", "POS", "REF", "ALT"))

# counts
sbs1_counts_fltr1 <- sapply(crispr1, function(x) {
  count <- count(sbs1[sbs1$Sample == x, ])
})
sbs1_counts_fltr1 <- t(as.data.frame(sbs1_counts_fltr1))
sbs1_counts_fltr1 <- cbind(sbs1_counts_fltr1, crispr1)
colnames(sbs1_counts_fltr1) <- c("count_fltr1", "sample")

sbs2_counts_fltr1 <- sapply(crispr2, function(x) {
  count <- count(sbs2[sbs2$Sample == x, ])
})
sbs2_counts_fltr1 <- t(as.data.frame(sbs2_counts_fltr1))
sbs2_counts_fltr1 <- cbind(sbs2_counts_fltr1, crispr2)
colnames(sbs1_counts_fltr1) <- c("count_fltr1", "sample")

sbs_fltr1_temp <- as.data.frame(rbind(sbs1_counts_fltr1, sbs2_counts_fltr1))
sbs_fltr1_temp <- sbs_fltr1_temp[order(match(sbs_fltr1_temp$sample, samples)), ]
sbs_counts <- sbs_counts[1:23, ]
sbs_counts$count_fltr1 <- sbs_fltr1_temp$count_fltr1
sbs_counts <- sbs_counts %>%
  relocate(count_fltr1, .after = raw_count)

id1_counts_fltr1 <- sapply(crispr1, function(x) {
  count <- count(id1[id1$Sample == x, ])
})
id1_counts_fltr1 <- t(as.data.frame(id1_counts_fltr1))
id1_counts_fltr1 <- cbind(id1_counts_fltr1, crispr1)
colnames(id1_counts_fltr1) <- c("count_fltr1", "sample")

id2_counts_fltr1 <- sapply(crispr2, function(x) {
  count <- count(id2[id2$Sample == x, ])
})
id2_counts_fltr1 <- t(as.data.frame(id2_counts_fltr1))
id2_counts_fltr1 <- cbind(id2_counts_fltr1, crispr2)
colnames(id1_counts_fltr1) <- c("count_fltr1", "sample")

id_fltr1_temp <- as.data.frame(rbind(id1_counts_fltr1, id2_counts_fltr1))
id_fltr1_temp <- id_fltr1_temp[order(match(id_fltr1_temp$sample, samples)), ]
id_counts <- id_counts[1:23, ]
id_counts$count_fltr1 <- id_fltr1_temp$count_fltr1
id_counts <- id_counts %>%
  relocate(count_fltr1, .after = raw_count)

## FILTER 2 ##
sbs1 <- sbs1 %>%
  group_by(across(1:4)) %>%
  filter(n_distinct(Sample) <= 2) %>%
  ungroup()

sbs2 <- sbs2 %>%
  group_by(across(1:4)) %>%
  filter(n_distinct(Sample) <= 2) %>%
  ungroup()

id1 <- id1 %>%
  group_by(across(1:4)) %>%
  filter(n_distinct(Sample) <= 2) %>%
  ungroup()

id2 <- id2 %>%
  group_by(across(1:4)) %>%
  filter(n_distinct(Sample) <= 2) %>%
  ungroup()

# counts
sbs1_counts_fltr2 <- sapply(crispr1, function(x) {
  count <- count(sbs1[sbs1$Sample == x, ])
})
sbs1_counts_fltr2 <- t(as.data.frame(sbs1_counts_fltr2))
sbs1_counts_fltr2 <- cbind(sbs1_counts_fltr2, crispr1)
colnames(sbs1_counts_fltr2) <- c("count_fltr2", "sample")

sbs2_counts_fltr2 <- sapply(crispr2, function(x) {
  count <- count(sbs2[sbs2$Sample == x, ])
})
sbs2_counts_fltr2 <- t(as.data.frame(sbs2_counts_fltr2))
sbs2_counts_fltr2 <- cbind(sbs2_counts_fltr2, crispr2)
colnames(sbs1_counts_fltr2) <- c("count_fltr2", "sample")

sbs_fltr2_temp <- as.data.frame(rbind(sbs1_counts_fltr2, sbs2_counts_fltr2))
sbs_fltr2_temp <- sbs_fltr2_temp[order(match(sbs_fltr2_temp$sample, samples)), ]
sbs_counts$count_fltr2 <- sbs_fltr2_temp$count_fltr2
sbs_counts <- sbs_counts %>%
  relocate(count_fltr2, .after = count_fltr1)

id1_counts_fltr2 <- sapply(crispr1, function(x) {
  count <- count(id1[id1$Sample == x, ])
})
id1_counts_fltr2 <- t(as.data.frame(id1_counts_fltr2))
id1_counts_fltr2 <- cbind(id1_counts_fltr2, crispr1)
colnames(id1_counts_fltr2) <- c("count_fltr2", "sample")

id2_counts_fltr2 <- sapply(crispr2, function(x) {
  count <- count(id2[id2$Sample == x, ])
})
id2_counts_fltr2 <- t(as.data.frame(id2_counts_fltr2))
id2_counts_fltr2 <- cbind(id2_counts_fltr2, crispr2)
colnames(id1_counts_fltr2) <- c("count_fltr2", "sample")

id_fltr2_temp <- as.data.frame(rbind(id1_counts_fltr2, id2_counts_fltr2))
id_fltr2_temp <- id_fltr2_temp[order(match(id_fltr2_temp$sample, samples)), ]
id_counts$count_fltr2 <- id_fltr2_temp$count_fltr2
id_counts <- id_counts %>%
  relocate(count_fltr2, .after = count_fltr1)

## FILTER 3 ##
dup <- duplicated(sbs1[, 1:4]) | duplicated(sbs1[, 1:4], fromLast = TRUE)
sbs1 <- sbs1[!dup, ]

dup <- duplicated(sbs2[, 1:4]) | duplicated(sbs2[, 1:4], fromLast = TRUE)
sbs2 <- sbs2[!dup, ]

dup <- duplicated(id1[, 1:4]) | duplicated(id1[, 1:4], fromLast = TRUE)
id1 <- id1[!dup, ]

dup <- duplicated(id2[, 1:4]) | duplicated(id2[, 1:4], fromLast = TRUE)
id2 <- id2[!dup, ]

# counts
sbs1_counts_fltr3 <- sapply(crispr1, function(x) {
  count <- count(sbs1[sbs1$Sample == x, ])
})
sbs1_counts_fltr3 <- t(as.data.frame(sbs1_counts_fltr3))
sbs1_counts_fltr3 <- cbind(sbs1_counts_fltr3, crispr1)
colnames(sbs1_counts_fltr3) <- c("count_fltr3", "sample")

sbs2_counts_fltr3 <- sapply(crispr2, function(x) {
  count <- count(sbs2[sbs2$Sample == x, ])
})
sbs2_counts_fltr3 <- t(as.data.frame(sbs2_counts_fltr3))
sbs2_counts_fltr3 <- cbind(sbs2_counts_fltr3, crispr2)
colnames(sbs1_counts_fltr3) <- c("count_fltr3", "sample")

sbs_fltr3_temp <- as.data.frame(rbind(sbs1_counts_fltr3, sbs2_counts_fltr3))
sbs_fltr3_temp <- sbs_fltr3_temp[order(match(sbs_fltr3_temp$sample, samples)), ]
sbs_counts$count_fltr3 <- sbs_fltr3_temp$count_fltr3
sbs_counts <- sbs_counts %>%
  relocate(count_fltr3, .after = count_fltr2)

id1_counts_fltr3 <- sapply(crispr1, function(x) {
  count <- count(id1[id1$Sample == x, ])
})
id1_counts_fltr3 <- t(as.data.frame(id1_counts_fltr3))
id1_counts_fltr3 <- cbind(id1_counts_fltr3, crispr1)
colnames(id1_counts_fltr3) <- c("count_fltr3", "sample")

id2_counts_fltr3 <- sapply(crispr2, function(x) {
  count <- count(id2[id2$Sample == x, ])
})
id2_counts_fltr3 <- t(as.data.frame(id2_counts_fltr3))
id2_counts_fltr3 <- cbind(id2_counts_fltr3, crispr2)
colnames(id1_counts_fltr3) <- c("count_fltr3", "sample")

id_fltr3_temp <- as.data.frame(rbind(id1_counts_fltr3, id2_counts_fltr3))
id_fltr3_temp <- id_fltr3_temp[order(match(id_fltr3_temp$sample, samples)), ]
id_counts$count_fltr3 <- id_fltr3_temp$count_fltr3
id_counts <- id_counts %>%
  relocate(count_fltr3, .after = count_fltr2)

# write out the count files
write.csv(sbs_counts, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/sbs_counts_my_filtering.csv")
write.csv(id_counts, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_counts_my_filtering.csv")
