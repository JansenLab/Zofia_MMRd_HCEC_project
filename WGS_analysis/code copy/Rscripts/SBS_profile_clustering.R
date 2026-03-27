### make a UMAP based on SBS catalogues ###

library(tidyverse)
library(signature.tools.lib)
library(umap)
library(ggrepel)

sbs <- read_delim('/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt', delim = '\t')
colnames(sbs)[1] <- "chr"
colnames(sbs)[2] <- "position"
sbs_by_sample <- split(sbs, sbs$Sample)

# create a de novo SBS catalogue per sample
sbs_cat <- lapply(sbs_by_sample, function(x) {
  tabToSNVcatalogue(x, genome.v = "hg38")
})

# join all catalogues into one df
cat_joint <- do.call(cbind, lapply(sbs_cat, `[[`, "catalogue"))
colnames(cat_joint) <- names(sbs_cat)
write_delim(cat_joint, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/sbs_denovo_catalogue.txt", delim='\t')

# umap w/o normalisation by total mutation number
# takes rows as data points - df needs to be transposed first
cat_joint_t <- t(cat_joint)
cat_joint_t <- as.data.frame(cat_joint_t)

#normalised data
cat_joint_t$sum <- rowSums(cat_joint_t) # calculate total mutation count
cat_joint_t_norm <- cat_joint_t[, 1:96]/cat_joint_t$sum

# umap (not normalised)
umap_result <- umap(cat_joint_t, n_neighbors = 15, min_dist = 0.1)
umap_df <- as.data.frame(umap_result$layout)
colnames(umap_df) <- c("UMAP1", "UMAP2")
umap_df$sample <- rownames(umap_df)

# umap (normalised)
umap_result_norm <- umap(cat_joint_t_norm, n_neighbors = 15, min_dist = 0.1)
umap_df_norm <- as.data.frame(umap_result_norm$layout)
colnames(umap_df_norm) <- c("UMAP1", "UMAP2")
umap_df_norm$sample <- rownames(umap_df_norm)

# assign clusters for colouring (know from the 1st run that there are 3 clusters)
umap_df_norm$cluster <- case_when(
  umap_df_norm$sample %in% c("HC1", "HC2", "MLH1-A6-PC", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2") ~ "Cluster 1",
  umap_df_norm$sample %in% c("F7-1", "C1-1", "A2-1", "A2-2", "C12-1", "C12-2") ~ "Cluster 2",
  TRUE ~ "Cluster 4"
)

## plot the umap
ggplot(umap_df_norm, aes(x = UMAP1, y = UMAP2, label = sample, color = cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text_repel(size = 3, max.overlaps = 20) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "UMAP of 96-channel SBS profiles")
 
### umap on mutator samples only

mutators <- umap_df_norm$sample[umap_df_norm$cluster %in% c("Cluster 2", "Cluster 4")]
cat_joint_t_norm_mut <- cat_joint_t_norm[rownames(cat_joint_t_norm) %in% mutators, ]

umap_result_norm_mut <- umap(cat_joint_t_norm_mut, n_neighbors = 15, min_dist = 0.1)
umap_df_norm_mut <- as.data.frame(umap_result_norm_mut$layout)
colnames(umap_df_norm_mut) <- c("UMAP1", "UMAP2")
umap_df_norm_mut$sample <- rownames(umap_df_norm_mut)
# adding a genotype column for colouring
lookup <- unique(sbs[, c("Sample", "KO")]) # extracting a lookup table of samples' genotypes
umap_df_norm_mut$KO <- lookup$KO[match(umap_df_norm_mut$sample, lookup$Sample)]

## plot
ggplot(umap_df_norm_mut, aes(x = UMAP1, y = UMAP2, label = sample, color = KO)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text_repel(size = 3, max.overlaps = 20) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  xlim(-2,2) +
  ylim(-2,2) +
  labs(title = "UMAP of 96-channel SBS profiles of hypermutator samples")


### PCA ###
## all samples
cat_joint_t_norm <- cat_joint_t_norm[
  !rownames(cat_joint_t_norm) %in% c("MLH1-A6-PC", "D6B"),
  ,
  drop = FALSE
]

pca_norm <- prcomp(cat_joint_t_norm, scale. = FALSE)

plot_df <- as.data.frame(pca_norm$x[, 1:2])
plot_df$sample <- rownames(cat_joint_t_norm)

plot_df$Cluster <- case_when(
  plot_df$sample %in% c("HC1", "HC2", "MLH1-A6-PC", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2") ~ "Low-mutators",
  plot_df$sample %in% c("F7-1", "C1-1", "A2-1", "A2-2", "C12-1", "C12-2") ~ "CRISPR1 hypermutators",
  TRUE ~ "CRISPR2 hypermutators"
)

# % variance explained
var_expl <- (pca_norm$sdev^2) / sum(pca_norm$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

# min_x = min(plot_df$PC1)
# max_x = max(plot_df$PC1)
# min_y = min(plot_df$PC2)
# max_y = max(plot_df$PC2)

ggplot(plot_df, aes(x = PC1, y = PC2, label = sample, color = Cluster)) + # not labelling by sample because there is too much overlap
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
  labs(title = "PCA of the 96-channel SBS profiles",
       x = pc1_label,
       y = pc2_label
      )

# calculate the top 3 variables contributing to PC1 and PC2

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

top_PC1 <- top_contributors(pca_norm$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm$rotation, "PC2", 3)

top_PC1
top_PC2


## mutators

mutators <- plot_df$sample[plot_df$Cluster %in% c("CRISPR1 hypermutators", "CRISPR2 hypermutators")]
cat_joint_t_norm_mut <- cat_joint_t_norm[rownames(cat_joint_t_norm) %in% mutators, ]

pca_norm_mut <- prcomp(cat_joint_t_norm_mut, scale. = FALSE)

plot_df_mut <- as.data.frame(pca_norm_mut$x[, 1:2])
plot_df_mut$sample <- rownames(cat_joint_t_norm_mut)

# adding a genotype column for colouring
plot_df_mut$Genotype <- lookup$KO[match(plot_df_mut$sample, lookup$Sample)]

# % variance explained
var_expl <- (pca_norm_mut$sdev^2) / sum(pca_norm_mut$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_df_mut, aes(x = PC1, y = PC2, label = sample, color = Genotype)) + # not labelling by sample because there is too much overlap
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
  labs(title = "PCA of the 96-channel SBS profiles of hypermutator samples",
       x = pc1_label,
       y = pc2_label
       )

# top 3 contributors to variance
top_PC1 <- top_contributors(pca_norm_mut$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm_mut$rotation, "PC2", 3)

top_PC1
top_PC2

## non-mutators
non_mutators <- plot_df$sample[!plot_df$Cluster %in% c("CRISPR1 hypermutators", "CRISPR2 hypermutators")]
cat_joint_t_norm_non_mut <- cat_joint_t_norm[rownames(cat_joint_t_norm) %in% non_mutators, ]
# remove MLH1-A6-PC to focus on the subclones
cat_joint_t_norm_non_mut <- cat_joint_t_norm_non_mut[rownames(cat_joint_t_norm_non_mut) != 'MLH1-A6-PC', ]

pca_norm_non_mut <- prcomp(cat_joint_t_norm_non_mut, scale. = FALSE)

plot_df_non_mut <- as.data.frame(pca_norm_non_mut$x[, 1:2])
plot_df_non_mut$sample <- rownames(cat_joint_t_norm_non_mut)
plot_df_non_mut$Genotype <- lookup$KO[match(plot_df_non_mut$sample, lookup$Sample)]

# % variance explained
var_expl <- (pca_norm_non_mut$sdev^2) / sum(pca_norm_non_mut$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_df_non_mut, aes(x = PC1, y = PC2, label = sample, color = Genotype)) + # not labelling by sample because there is too much overlap
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
  labs(title = "PCA of the 96-channel SBS profiles of low-mutator samples",
       x = pc1_label,
       y = pc2_label
       )

# top 3 contributors to variance
top_PC1 <- top_contributors(pca_norm_non_mut$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_norm_non_mut$rotation, "PC2", 3)

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
  labs(title = "PCA of subclones with MLH1, MSH3 and MBD4 KOs",
       x = pc1_label,
       y = pc2_label
  )

# top 3 contributors to variance
top_PC1 <- top_contributors(pca$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca$rotation, "PC2", 3)

top_PC1
top_PC2

## MSH3 alone ##
MSH3 <- input[c("C1-2", "F7-2", "F10-1", "F10-2", "D4_1", "D6_1"), ]

pca_MSH3 <- prcomp(MSH3, scale. = FALSE)
plot_MSH3 <- as.data.frame(pca_MSH3$x[, 1:2])
plot_MSH3$sample <- rownames(MSH3)
plot_MSH3$KO <- lookup$KO[match(plot_MSH3$sample, lookup$Sample)]

var_expl <- (pca_MSH3$sdev^2) / sum(pca_MSH3$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_MSH3, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "PCA of MSH3-/- and MLH1-/-MSH3-/- samples",
       x = pc1_label,
       y = pc2_label
  )

top_PC1 <- top_contributors(pca_MSH3$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_MSH3$rotation, "PC2", 3)

top_PC1
top_PC2

## MBD4 alone ##
MBD4 <- input[c("H2-1", "H2-2", "E5_1", "E5_2", "E8_1", "E8_2"), ]

pca_MBD4 <- prcomp(MBD4, scale. = FALSE)
plot_MBD4 <- as.data.frame(pca_MBD4$x[, 1:2])
plot_MBD4$sample <- rownames(MBD4)
plot_MBD4$KO <- lookup$KO[match(plot_MBD4$sample, lookup$Sample)]

var_expl <- (pca_MBD4$sdev^2) / sum(pca_MBD4$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_MBD4, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "PCA of MBD4-/- and MLH1-/-MBD4-/- samples",
       x = pc1_label,
       y = pc2_label
  )

top_PC1 <- top_contributors(pca_MBD4$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_MBD4$rotation, "PC2", 3)

top_PC1
top_PC2

## MLH1 ##

MLH1 <- input[c("A2-1", "A2-2", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2"), ]

pca_MLH1 <- prcomp(MLH1, scale. = FALSE)
plot_MLH1 <- as.data.frame(pca_MLH1$x[, 1:2])
plot_MLH1$sample <- rownames(MLH1)
plot_MLH1$KO <- lookup$KO[match(plot_MLH1$sample, lookup$Sample)]

var_expl <- (pca_MLH1$sdev^2) / sum(pca_MLH1$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_MLH1, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(#title = "PCA of subclones with single MLH1 KO and MLH1 KO combined with MSH3 or MBD4 KO",
       x = pc1_label,
       y = pc2_label
  )

top_PC1 <- top_contributors(pca_MLH1$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_MLH1$rotation, "PC2", 3)

top_PC1
top_PC2

## MLH1MSH3 ##
MLH1MSH3 <- input[c("A2-1", "A2-2", "D4_1", "D6_1"), ]

pca_MLH1MSH3 <- prcomp(MLH1MSH3, scale. = FALSE)
plot_MLH1MSH3 <- as.data.frame(pca_MLH1MSH3$x[, 1:2])
plot_MLH1MSH3$sample <- rownames(MLH1MSH3)
plot_MLH1MSH3$KO <- lookup$KO[match(plot_MLH1MSH3$sample, lookup$Sample)]

var_expl <- (pca_MLH1MSH3$sdev^2) / sum(pca_MLH1MSH3$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_MLH1MSH3, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "PCA of subclones with single MLH1 KO and MLH1 KO combined with MSH3 KO",
       x = pc1_label,
       y = pc2_label
  )

top_PC1 <- top_contributors(pca_MLH1MSH3$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_MLH1MSH3$rotation, "PC2", 3)

top_PC1
top_PC2

## MLH1MBD4 ##
MLH1MBD4 <- input[c("A2-1", "A2-2", "E5_1", "E5_2", "E8_1", "E8_2"), ]

pca_MLH1MBD4 <- prcomp(MLH1MBD4, scale. = FALSE)
plot_MLH1MBD4 <- as.data.frame(pca_MLH1MBD4$x[, 1:2])
plot_MLH1MBD4$sample <- rownames(MLH1MBD4)
plot_MLH1MBD4$KO <- lookup$KO[match(plot_MLH1MBD4$sample, lookup$Sample)]

var_expl <- (pca_MLH1MBD4$sdev^2) / sum(pca_MLH1MBD4$sdev^2)
pc1_label <- paste0("PC1 (", round(var_expl[1] * 100, 1), "%)")
pc2_label <- paste0("PC2 (", round(var_expl[2] * 100, 1), "%)")

ggplot(plot_MLH1MBD4, aes(x = PC1, y = PC2, label = sample, color = KO)) + # not labelling by sample because there is too much overlap
  geom_point(size = 3) +
  geom_text_repel() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  labs(title = "PCA of subclones with single MLH1 KO and MLH1 KO combined with MBD4 KO",
       x = pc1_label,
       y = pc2_label
  )

top_PC1 <- top_contributors(pca_MLH1MBD4$rotation, "PC1", 3)
top_PC2 <- top_contributors(pca_MLH1MBD4$rotation, "PC2", 3)

top_PC1
top_PC2

###############

CCTCAT <- as.data.frame(cat_joint_t_norm[, "C[C>A]T"])
rownames(CCTCAT) <- rownames(cat_joint_t_norm)
CCTCAT$KO <- lookup$KO[match(rownames(CCTCAT), lookup$Sample)]
colnames(CCTCAT) <- c("value", "KO")

CCTCAT <- CCTCAT %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

GCCGTC <- as.data.frame(cat_joint_t[, "G[C>T]C"])
rownames(GCCGTC) <- rownames(cat_joint_t)
GCCGTC$KO <- lookup$KO[match(rownames(GCCGTC), lookup$Sample)]
colnames(GCCGTC) <- c("value", "KO")

GCCGTC <- GCCGTC%>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

GTAGCA <- as.data.frame(cat_joint_t[, "G[T>C]A"])
rownames(GTAGCA) <- rownames(cat_joint_t)
GTAGCA$KO <- lookup$KO[match(rownames(GTAGCA), lookup$Sample)]
colnames(GTAGCA) <- c("value", "KO")

GTAGCA <- GTAGCA%>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

GCTGAT <- as.data.frame(cat_joint_t[, "G[C>A]T"])
rownames(GCTGAT) <- rownames(cat_joint_t)
GCTGAT$KO <- lookup$KO[match(rownames(GCTGAT), lookup$Sample)]
colnames(GCTGAT) <- c("value", "KO")

GCTGAT <- GCTGAT %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

GCTGAT <- as.data.frame(cat_joint_t_norm[, "G[C>A]T"])
rownames(GCTGAT) <- rownames(cat_joint_t_norm)
GCTGAT$KO <- lookup$KO[match(rownames(GCTGAT), lookup$Sample)]
colnames(GCTGAT) <- c("value", "KO")

GCTGAT <- GCTGAT %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

TCTTAT <- as.data.frame(cat_joint_t_norm[, "T[C>A]T"])
rownames(TCTTAT) <- rownames(cat_joint_t_norm)
TCTTAT$KO <- lookup$KO[match(rownames(TCTTAT), lookup$Sample)]
colnames(TCTTAT) <- c("value", "KO")

TCTTAT <- TCTTAT %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

CCACAA <- as.data.frame(cat_joint_t_norm[, "C[C>A]A"])
rownames(CCACAA) <- rownames(cat_joint_t_norm)
CCACAA$KO <- lookup$KO[match(rownames(CCACAA), lookup$Sample)]
colnames(CCACAA) <- c("value", "KO")

CCACAA <- CCACAA %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

CCCCAC <- as.data.frame(cat_joint_t_norm[, "C[C>A]C"])
rownames(CCCCAC) <- rownames(cat_joint_t_norm)
CCCCAC$KO <- lookup$KO[match(rownames(CCCCAC), lookup$Sample)]
colnames(CCCCAC) <- c("value", "KO")

CCCCAC <- CCCCAC %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

ACTAAT <- as.data.frame(cat_joint_t_norm[, "A[C>A]T"])
rownames(ACTAAT) <- rownames(cat_joint_t_norm)
ACTAAT$KO <- lookup$KO[match(rownames(ACTAAT), lookup$Sample)]
colnames(ACTAAT) <- c("value", "KO")

ACTAAT <- ACTAAT %>%
  group_by(KO) %>%
  mutate(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()
