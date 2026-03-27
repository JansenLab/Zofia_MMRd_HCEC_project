# analysing structural variants called by Gene with BRASS #

library(paletteer)
library(tidyverse)
library(data.table)

# loading the data
SV <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/combined_bedpe.txt", sep = "\t", header = T)

# cleaning the data
# removing CRISPR A6 samples
samList_unclean <- unique(SV$sample)
SV <- SV[!(SV$sample %in% c("A6-1", "A6-2", "A5A", "A5A,HCEC-MC", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
print(unique(SV$sample))
samList_clean <- unique(SV$Sample) # generating the final sample list
print(samList_clean)
# save raw data without A6-derived clones
write_delim(SV,"/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/SV_noA6clones.txt", delim = "\t")

# count the number of each type of SV per sample
SV_counts <- lapply(samList_clean, function(sample) {
  dels <- sum(SV$Sample == sample & SV$svclass == "deletion")
  td   <- sum(SV$Sample == sample & SV$svclass == "tandem-duplication")
  tl   <- sum(SV$Sample == sample & SV$svclass == "translocation")
  inv  <- sum(SV$Sample == sample & SV$svclass == "inversion")
  
  # Return a named vector for each sample
  return(data.frame(
    Sample = sample,
    Deletions = dels,
    TandemDuplications = td,
    Translocations = tl,
    Inversions = inv
  ))
})

# Combine all rows into one data frame
SV_counts_df <- do.call(rbind, SV_counts)

# order the SV_counts_df
SV_counts_df <- SV_counts_df[c(22:24, 1:2, 4, 18, 5:7, 19, 16:17, 20:21, 8, 3, 11, 9:10, 12:15), ]
# save the file with SV counts
write_delim(SV_counts_df, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/SV_counts.csv", delim=",")
# melt to plot
final_SV_df <- pivot_longer(SV_counts_df, cols = 2:5, names_to = "SV_type", values_to = "count")

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart (chatgpt adjusted code)
# Plot with wider bars and aligned elements
p <- ggplot(final_SV_df, aes(x = Sample, y = count, fill = SV_type)) +
  geom_bar(stat = "identity", position = position_dodge(), width = 2)

# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = final_SV_df$Sample) +
  scale_fill_manual(
    values = c("#3294DDFF", "#75FB8AFF", "#CB64C0FF", "#FD6598FF"),
    labels = c("Deletions", "Tandem duplications", "Translocations", "Inversions")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, size = 12, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.x = element_text(size = 17, vjust = 7),
    axis.title.y = element_text(size = 17, vjust = 2.3),
    plot.title = element_text(size = 10),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    legend.position = c(0.15, 0.85),
    legend.title = element_blank(),
    legend.text = element_text(size = 12),
    legend.key.size = unit(8, "mm")
  ) +
  labs(
    x = "Sample",
    y = "SV count"
  )

print(p)
