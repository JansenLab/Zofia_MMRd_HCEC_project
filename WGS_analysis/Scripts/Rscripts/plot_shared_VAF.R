# script to make shared plots #

library(ggplot2)
library(cowplot)
library(eulerr)
library(viridis)
library(dplyr)
library(purrr)

# sample list
cloneList <- c("HC","A2", "A6", "C1", "C12", "F7", "F10", "H2", "A5", "A6_CRISPR2", "B7", "B8", "C7", "C8")

samList <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv")
samList <- unique(samList[, 1:3])
samList[,2] <- paste0(samList$clone, samList$subclone)

# list of csv files to import
dir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_snvs_per_clone/"
pathList <- lapply(cloneList, function(sample) {
  paste0(dir, sample, "_shared_variants.csv")
})
print(pathList)

# list of csv files
csvList <- lapply(pathList, function(sample) {
  read.csv(sample)
})
summary(csvList)

### plotting VAF spectra ###
# two small graphs next to each other for each subclones

cloneList[[9]] <- "A6"

pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_snvs_per_clone/shared_VAF.pdf")

# CRISPR1 plots
plots_CR1 <- lapply(seq_along(1:7), function(sample) {
  vaf1 <- csvList[[sample]][, 6]
  vaf2 <- csvList[[sample]][, 7]
  
  p1 <- ggplot() +
    geom_histogram(aes(x = vaf1), bins = 100) +
    labs(title = paste0(cloneList[[sample]], "-1"), x = "VAF", y = "count") +
    theme_light()
  
  p2 <- ggplot() +
    geom_histogram(aes(x = vaf2), bins = 100) +
    labs(title = paste0(cloneList[[sample]], "-2"), x = "VAF", y = "count") +
    theme_light()
  
  grid <- plot_grid(p1, p2, ncol = 2)
  print(grid)
})

# CRISPR2 plots
plots_CR2 <- lapply(8:14, function(sample) {
  vaf1 <- csvList[[sample]][, 6]
  vaf2 <- csvList[[sample]][, 7]
  
  p1 <- ggplot() +
    geom_histogram(aes(x = vaf1), bins = 100) +
    labs(title = paste0(cloneList[[sample]], "A"), x = "VAF", y = "count") +
    theme_light()
  
  p2 <- ggplot() +
    geom_histogram(aes(x = vaf2), bins = 100) +
    labs(title = paste0(cloneList[[sample]], "B"), x = "VAF", y = "count") +
    theme_light()
  
  grid <- plot_grid(p1, p2, ncol = 2)
  print(grid)
})

dev.off()

### Venn diagrams ###

shared_snvs <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_snvs_per_clone/shared_snvs.csv")

pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_MC/shared_snvs_per_clone/venn_diagrams.pdf")

indices <- seq(1, nrow(shared_snvs), by = 2)
num_plots <- length(indices)
# Generate a list of viridis colors, with each plot potentially having 3 regions (A, B, A&B)
colors <- viridis(num_plots * 3) 

euler_plots <- lapply(seq_along(indices), function(i) {
  sample <- indices[i]
  
  names <- c(shared_snvs$sample[[sample]], shared_snvs$sample[[sample+1]])
  euler_data <- c(A = shared_snvs$snv_count[[sample]], 
                  B = shared_snvs$snv_count[[sample+1]], 
                  "A&B" = shared_snvs$shared_count_snv[[sample]])
  
  euler_graph <- euler(euler_data)
  # Extract the specific colors for this plot
  plot_colors <- colors[((i - 1) * 3 + 1):(i * 3)]
  # calculates starting and ending index for the color subset from viridis palette for ith plot
  alpha_values <- c(0.6, 0.3, 1)
  
  print(plot(euler_graph, labels = names, quantities = TRUE, fills = list(fill = plot_colors, alpha = alpha_values)))
})

dev.off()  





