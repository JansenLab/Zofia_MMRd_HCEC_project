### plotting VAF spectra for variants from Gene ###

library(data.table)
library(tidyverse)
library(patchwork)

### ANALYSIS OF MERGED DE NOVO VARIANTS ###

# loading mutation data
subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)
ids <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)

samList <- unique(subs$Sample) # extracting sample names
KOlist <- sapply(samList, function(sample) {
  unique(subs$KO[subs$Sample == sample])
})

### SUBSTITUTION ANALYSIS ###

# splitting the subs tibble per sample
subs_by_sample <- lapply(samList, function(sample) {
  variants <- subs %>% filter(Sample == sample)
  return(variants)
})

# obtaining list of VAF values for variants in each sample
vaf_list_subs <- lapply(subs_by_sample, function(sample) {
  # iterating over rows in the TUMOUR column 
  vaf_per_sample <- lapply(seq_along(sample$TUMOUR), function(i) {
      vaf <- strsplit(sample$TUMOUR[i], ":")
      return(vaf[[1]][10])
  })
  return(vaf_per_sample)
})

# calculating average VAFs per sample
vaf_list_subs <- lapply(vaf_list_subs, as.numeric)
mean_vaf <- sapply(seq_along(vaf_list_subs), function(i) {
  m <- mean(vaf_list_subs[[i]])
})

# save file
mean_df <- data.frame(sample = samList, mean_vaf = mean_vaf)
write_delim(mean_df, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mean_sub_vaf_denovo.txt")

# plotting histograms of VAF per sample
plots_subs <- lapply(seq_along(vaf_list_subs), function(i) {
  sample <- samList[i]
  VAF <- as.numeric(unlist(vaf_list_subs[[i]]))
  
  p <- ggplot() +
    geom_histogram(aes(x = VAF), bins = 100) +
    labs(title = paste0(sample, ": ", KOlist[i]), x = "VAF", y = "count") +
    theme_light() +
    annotate("text", 
             x = -Inf, y = Inf,                  
             label = paste0(round(mean_vaf[i], 2)),
             hjust = -0.1, vjust = 1.5,
             color = "black", size = 3) +
    theme(plot.title = element_text(size = 10, face = "bold", hjust = 0))
})

for (p in plots_subs) print(p)


### INDEL ANALYSIS ###

# splitting the indels file by sample
ids_by_sample <- lapply(samList, function(sample) {
  variants <- ids %>% filter(Sample == sample)
  return(variants)
})

# obtaining list of VAF values for variants in each sample
vaf_list_ids <- lapply(ids_by_sample, function(sample) {
  # iterating over rows in the TUMOUR column 
  vaf_per_sample <- lapply(seq_along(sample$TUMOUR), function(i) {
    
    string <- as.numeric(unlist(strsplit(sample$TUMOUR[i], ":")))
    
    PU <- string[10]
    NU <- string[11]
    PR <- string[8]
    NR <- string[9]
    
    vaf <- ((PU+NU)/(PR+NR))
    return(vaf)
    
  })
  return(vaf_per_sample)
})

# calculate mean VAF
vaf_list_ids <- lapply(vaf_list_ids, as.numeric)
mean_vaf_id <- sapply(seq_along(vaf_list_ids), function(i) {
  m <- mean(vaf_list_ids[[i]])
})

# plotting histograms of VAF per sample

plots_id <- lapply(seq_along(vaf_list_ids), function(i) {
  sample <- samList[i]
  VAF <- as.numeric(unlist(vaf_list_ids[[i]]))
  
  p <- ggplot() +
    geom_histogram(aes(x = VAF), bins = 100) +
    labs(title = paste0(sample, ": ", KOlist[i]), x = "VAF", y = "count") +
    theme_light() +
    annotate("text", 
             x = -Inf, y = Inf,                  
             label = paste0(round(mean_vaf_id[i], 2)),
             hjust = -0.1, vjust = 1.5,
             color = "black", size = 3) +
  theme(plot.title = element_text(size = 10, face = "bold", hjust = 0))
  
})

for (p in plots_id) print(p)

# plot as a grid
wrap_plots(plots_subs, ncol = 6, nrow = 4) # from the patchwork package
wrap_plots(plots_id, ncol = 6, nrow = 4) # from the patchwork package



### WGS_2 SAMPLES ###

subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/substitutions/caveman_may25.txt", sep = "\t", header = T)
ids <- fread("//Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/indels/combined_pindel_may25.tsv", sep = "\t", header = T)
# subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/substitutions/substitution_denovo_may25.txt", sep = "\t", header = T)
# ids <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch2_30x/indels/indels_denovo_may25.txt", sep = "\t", header = T)

# simplify the sample names
subs$Sample <- lapply(subs$Sample, function(x) {sub("_vs_HCEC-MC", "", x)})
ids$Sample <- lapply(ids$Sample, function(x) {sub("_vs_HCEC-MC", "", x)})
print(subs$Sample)
print(ids$Sample)

# remove unsuccessful CRISPR2 KOs from the subs table 
subs <- subs[(subs$Sample %in% c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")), ]
print(unique(subs$Sample)) # check if it worked
ids <- ids[(ids$Sample %in% c("C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")), ]
print(unique(ids$Sample)) # check if it worked

# extracting sample names
samList <- unique(subs$Sample)
# generating a KO list
KOlist2 <- c("MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-")

### the data is now cleaned ###
### SUBSTITUTION ANALYSIS ###

# splitting the subs tibble per sample
subs_by_sample <- lapply(samList, function(sample) {
  variants <- subs %>% filter(Sample == sample)
  return(variants)
})

# obtaining list of VAF values for variants in each sample
vaf_list_subs <- lapply(subs_by_sample, function(sample) {
  # iterating over rows in the TUMOUR column 
  vaf_per_sample <- lapply(seq_along(sample$TUMOUR), function(i) {
    vaf <- strsplit(sample$TUMOUR[i], ":")
    return(vaf[[1]][10])
  })
  return(vaf_per_sample)
})

# calculating average VAFs per sample
vaf_list_subs <- lapply(vaf_list_subs, as.numeric)
mean_vaf <- sapply(seq_along(vaf_list_subs), function(i) {
  m <- mean(vaf_list_subs[[i]])
})

mean_df <- data.frame(sample = unlist(samList), mean_vaf = mean_vaf)

# plotting histograms of VAF per sample
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/VAF_WGS2_denovo_subs.pdf")

plots2_subs <- lapply(seq_along(vaf_list_subs), function(i) {
  sample <- samList[i]
  VAF <- as.numeric(unlist(vaf_list_subs[[i]]))
  
  p <- ggplot() +
    geom_histogram(aes(x = VAF), bins = 100) +
    labs(title = paste0(sample, ": ", KOlist2[i]), x = "VAF", y = "count") +
    theme_light()
  
  print(p)
})

dev.off()

### INDEL ANALYSIS ###

# splitting the indels file by sample
ids_by_sample <- lapply(samList, function(sample) {
  variants <- ids %>% filter(Sample == sample)
  return(variants)
})

# obtaining list of VAF values for variants in each sample
vaf_list_ids <- lapply(ids_by_sample, function(sample) {
  # iterating over rows in the TUMOUR column 
  vaf_per_sample <- lapply(seq_along(sample$TUMOUR), function(i) {
    
    string <- as.numeric(unlist(strsplit(sample$TUMOUR[i], ":")))
    
    PU <- string[10]
    NU <- string[11]
    PR <- string[8]
    NR <- string[9]
    
    vaf <- ((PU+NU)/(PR+NR))
    return(vaf)
    
  })
  return(vaf_per_sample)
})

# plotting histograms of VAF per sample
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/VAF_WGS2_denovo_ids.pdf")

plots2_id <- lapply(seq_along(vaf_list_ids), function(i) {
  sample <- samList[i]
  VAF <- as.numeric(unlist(vaf_list_ids[[i]]))
  
  p <- ggplot() +
    geom_histogram(aes(x = VAF), bins = 100) +
    labs(title = paste0(sample, ": ", KOlist2[i]), x = "VAF", y = "count") +
    theme_light()
  
  print(p)
})

dev.off()

### GENERATING FINAL PLOT GRID ###

# substitutions #
all_subs_plots <- c(plots1_subs, plots2_subs)
all_subs_plots <- all_subs_plots[c(14:16, 1:3, 10, 4:6, 11, 8:9, 12:13, 17:18, 7, 19:24)]
wrap_plots(all_subs_plots, ncol = 6, nrow = 4) # from the patchwork package

# indels #
all_ids_plots <- c(plots1_id, plots2_id)
all_ids_plots <- all_ids_plots[c(12:13, 1, 4:5, 6:7, 3, 8:9, 11, 18, 2, 14:15, 16:17, 10, 19:24)]
wrap_plots(all_ids_plots, ncol = 6, nrow = 4) # from the patchwork package
