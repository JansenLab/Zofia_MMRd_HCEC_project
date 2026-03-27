### clustering Gene's 89-channel indel profiles ###

library(tidyverse)
library(indelsig.tools.lib)
library(umap)
library(ggrepel)

id <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", delim="\t")
id_per_sample <- split(id, id$Sample)

# formatting the data
id_per_sample <- lapply(id_per_sample, function(x) {
  x <- x[, c(1:2, 4:5, 12)]
  colnames(x) <- c("chr", "position", "REF", "ALT", "sample")
  return(x)
})

# indel segmentation
id_segmented <- lapply(id_per_sample, function(sample) {
  seg <- indel_classifier89(sample, "hg38")
  return(seg)
})

# generating 89-channel catalogues
id_catalogues <- lapply(id_segmented, function(sample) {
  catalogue <- gen_catalogue89(sample, sample_col = 4)
  return(catalogue)
})

# join all catalogues into one df
cat_joint <- do.call(cbind, id_catalogues)
write_delim(cat_joint, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_catalogue.txt", delim='\t')

# PCA w/o normalisation by total mutation number
# takes rows as data points - df needs to be transposed first
cat_joint_t <- t(cat_joint)
cat_joint_t <- as.data.frame(cat_joint_t)
cat_joint_t <- cat_joint_t[!rownames(cat_joint_t) %in% c("MLH1-A6-PC"), ]

pca <- prcomp(cat_joint_t, scale. = FALSE)

plot_df <- as.data.frame(pca$x[, 1:2])
plot_df$sample <- rownames(cat_joint_t)

# add genotype column to colour by
lookup <- unique(id[, c("Sample", "KO")]) # extracting a lookup table of samples' genotypes
plot_df$KO <- lookup$KO[match(plot_df$sample, lookup$Sample)]

plot_df$cluster <- case_when(
  plot_df$sample %in% c("HC1", "HC2", "MLH1-A6-PC", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2") ~ "Cluster 1",
  plot_df$sample %in% c("F7-1", "C1-1", "A2-1", "A2-2", "C12-1", "C12-2") ~ "Cluster 2",
  TRUE ~ "Cluster 3"
)

p <- ggplot(plot_df, aes(x = PC1, y = PC2, label = sample, color = cluster)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "PCA of 89-channel indel profiles")
print(p)

# pca with normalisation 
#normalised data
cat_joint_t$sum <- rowSums(cat_joint_t) # calculate total mutation count
cat_joint_t_norm <- cat_joint_t[, 1:ncol(cat_joint_t)]/cat_joint_t$sum
cat_joint_t_norm <- cat_joint_t_norm[!rownames(cat_joint_t_norm) %in% c('MLH1-A6-PC'), ]
pca_norm <- prcomp(cat_joint_t_norm, scale. = FALSE)

plot_df_norm <- as.data.frame(pca_norm$x[, 1:2])
plot_df_norm$sample <- rownames(cat_joint_t_norm)

# add genotype column to colour by
plot_df_norm$Genotype <- lookup$KO[match(plot_df_norm$sample, lookup$Sample)]

plot_df_norm$cluster <- case_when(
  plot_df_norm$sample %in% c("HC1", "HC2", "MLH1-A6-PC", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2") ~ "Low-mutators",
  plot_df_norm$sample %in% c("F7-1", "C1-1", "A2-1", "A2-2", "C12-1", "C12-2") ~ "CRISPR1 hypermutators",
  TRUE ~ "CRISPR2 hypermutators"
)

# % variance explained
var_expl <- (pca_norm$sdev^2) / sum(pca_norm$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

p_norm <- ggplot(plot_df_norm, aes(x = PC1, y = PC2, label = sample, color = cluster)) + # not labelling by sample because there is too much overlap
  geom_point(size = 5, alpha = 0.8) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(size = 24, hjust = 0.5,  margin = margin(t = 10)), # margin adds space above the plot title, pushing it down
        axis.title.x = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        legend.title = element_text(size = 18),
        legend.text  = element_text(size = 16),
        legend.position="right") +
  labs(title = "PCA of the 89-channel indel profiles",
       x = pc1_label,
       y = pc2_label
       )
print(p_norm)

# Function to get top contributing variables for a given PC
top_contributors <- function(rotation_matrix, pc, n = 3) {
  loads <- rotation_matrix[, pc]
  abs_loads <- abs(loads)
  top_idx <- order(abs_loads, decreasing = TRUE)[1:n]
  data.frame(
    Variable = rownames(rotation_matrix)[top_idx],
    Loading = loads[top_idx],
    AbsLoading = abs_loads[top_idx]
  )
}

# top 3 contributors to variance
top_PC1 <- top_contributors(pca_norm$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm$rotation, "PC2", 3)

top_PC1
top_PC2


# mutators
mutators <- plot_df_norm$sample[plot_df_norm$cluster %in% c("CRISPR1 hypermutators", "CRISPR2 hypermutators")]
cat_joint_t_norm_mut <- cat_joint_t_norm[rownames(cat_joint_t_norm) %in% mutators, ]

pca_norm_mut <- prcomp(cat_joint_t_norm_mut, scale. = FALSE)

plot_df_mut <- as.data.frame(pca_norm_mut$x[, 1:2])
plot_df_mut$sample <- rownames(cat_joint_t_norm_mut)

plot_df_mut$Genotype <- lookup$KO[match(plot_df_mut$sample, lookup$Sample)]

# % variance explained
var_expl <- (pca_norm_mut$sdev^2) / sum(pca_norm_mut$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

p_mut <- ggplot(plot_df_mut, aes(x = PC1, y = PC2, label = sample, color = Genotype)) + # not labelling by sample because there is too much overlap
  geom_point(size = 5, alpha = 0.8) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(size = 24, hjust = 0.5,  margin = margin(t = 10)), # margin adds space above the plot title, pushing it down
         axis.title.x = element_text(size = 18),
         axis.title.y = element_text(size = 18),
         axis.text.x = element_text(size = 12),
         axis.text.y = element_text(size = 12),
         legend.title = element_text(size = 18),
         legend.text  = element_text(size = 16),
         legend.position="right") +
  labs(title = "PCA of the 89-channel indel profiles of hypermutator samples",
       x = pc1_label,
       y = pc2_label
       )
print(p_mut)

# top 3 contributors to variance
top_PC1 <- top_contributors(pca_norm_mut$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm_mut$rotation, "PC2", 3)

top_PC1
top_PC2

# nonmutators
nonmutators <- plot_df_norm$sample[!plot_df_norm$cluster %in% c("CRISPR1 hypermutators", "CRISPR2 hypermutators")]
cat_joint_t_norm_nonmut <- cat_joint_t_norm[rownames(cat_joint_t_norm) %in% nonmutators, ]

pca_norm_nonmut <- prcomp(cat_joint_t_norm_nonmut, scale. = FALSE)

plot_df_nonmut <- as.data.frame(pca_norm_nonmut$x[, 1:2])
plot_df_nonmut$sample <- rownames(cat_joint_t_norm_nonmut)

plot_df_nonmut$Genotype <- lookup$KO[match(plot_df_nonmut$sample, lookup$Sample)]

# % variance explained
var_expl <- (pca_norm_nonmut$sdev^2) / sum(pca_norm_nonmut$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

p_nonmut <- ggplot(plot_df_nonmut, aes(x = PC1, y = PC2, label = sample, color = Genotype)) + # not labelling by sample because there is too much overlap
  geom_point(size = 5, alpha = 0.8) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(size = 24, hjust = 0.5,  margin = margin(t = 10)), # margin adds space above the plot title, pushing it down
        axis.title.x = element_text(size = 18),
        axis.title.y = element_text(size = 18),
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        legend.title = element_text(size = 18),
        legend.text  = element_text(size = 16),
        legend.position="right") +
  labs(title = "PCA of the 89-channel indel profiles of low-mutator samples",
       x = pc1_label,
       y = pc2_label
       )
print(p_nonmut)

# top 3 contributors to variance
top_PC1 <- top_contributors(pca_norm_nonmut$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm_nonmut$rotation, "PC2", 3)

top_PC1
top_PC2

### narrow down to MLH1, MSH3 and MBD4 KOs ###
samples <- c("A2-1", "A2-2", "C1-2", "F7-2", "F10-1", "F10-2", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2", "H2-1", "H2-2")
input <- cat_joint_t_norm[samples, ]

pca <- prcomp(input, scale. = FALSE)

plot_df <- as.data.frame(pca$x[, 1:2])
plot_df$sample <- rownames(input)

# adding a genotype column for colouring
plot_df$KO <- lookup$KO[match(plot_df$sample, lookup$Sample)]

# % variance explained
var_expl <- (pca$sdev^2) / sum(pca$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_df, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(#title = "PCA of subclones with MLH1, MSH3 and MBD4 KOs",
       x = pc1_label,
       y = pc2_label
  )

# top 3 contributors to variance
top_PC1 <- top_contributors(pca$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca$rotation, "PC2", 3)

top_PC1
top_PC2
