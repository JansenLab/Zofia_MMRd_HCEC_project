### filter mutations by VAF to calculate genotype-specific mutation rate ###

library(data.table)
library(tidyverse)

# read in the data - de novo mutations
subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)
ids <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)

# extracting sample names
samList <- unique(subs$Sample)
KO_list <- c("WT", "WT", "MLH1-/- (PC)", "MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/- (sim)", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-")

# obtaining list of VAF values for all subs
vaf_list_subs <- sapply(seq_len(nrow(subs)), function(i) {
    vaf <- strsplit(subs$TUMOUR[i], ":")
    return(vaf[[1]][10])
})
subs$vaf <- vaf_list_subs

# obtaining list of VAF values for all ids
vaf_list_ids <- sapply(seq_len(nrow(ids)), function(i) {
 
  string <- as.numeric(unlist(strsplit(ids$TUMOUR[i], ":")))
    
    PU <- string[10]
    NU <- string[11]
    PR <- string[8]
    NR <- string[9]
    
    vaf <- ((PU+NU)/(PR+NR))
    return(vaf)
})
ids$vaf <- vaf_list_ids

# filter for  0.2 < vaf < 0.4
subs_filt <- subs[subs$vaf > 0.2] #& subs$vaf < 0.4, ]
ids_filt <- ids[ids$vaf > 0.2] #& ids$vaf < 0.4, ]

# count filtered indels per sample
subs_counts <- sapply(samList, function(sample) {
  sum(subs_filt$Sample==sample)
})
ids_counts <- sapply(samList, function(sample) {
  sum(ids_filt$Sample==sample)
})
# save as a csv file
mut_counts_filt <- data.frame(sample = samList, KO = KO_list, sub_counts = subs_counts, id_counts = ids_counts)
write_csv(mut_counts_filt, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/denovo_mut_counts_filt_v2.csv")

### calculated mutation rate per cell division in excel ###

# read in the mutation rate file
mut_rate <- read_csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mut_rate_v2.csv")

# clean the data
mut_rate_clean <- mut_rate[ , c(1:2, 8:9)]
final_df <- pivot_longer(mut_rate_clean, cols = 3:4, names_to = "mut_type", values_to = "value")

# generating summary statistics
all_good_summary <- final_df %>%
  group_by(KO, mut_type) %>%
  summarise(
    NChild = length(value),
    mean = mean(value),
    sd = sd(value),
    .groups = "drop"
  )
all_good_summary[is.na(all_good_summary)] <- 0 # replace NAs with zeroes

# ordering the summary df
summary_ordered <- all_good_summary[c(17:18, 3:4, 15:16, 13:14, 1:2, 9:10, 11:12, 7:8, 5:6), ]

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart #
# PER GENOTYPE #
# Define a consistent dodge position matching the bar width
dodge <- position_dodge(width = 0.8)

# Plot with wider bars and aligned elements
p <- ggplot(summary_ordered, aes(x = KO, y = mean, fill = mut_type)) +
  geom_bar(stat = "identity", position = dodge, width = 0.8) +
  geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd),
              width=.2,                    # Width of the error bars
              position=position_dodge(.8))+ geom_point(data=final_df,aes(x=KO, y=value),position=position_jitterdodge(0.1),show.legend = FALSE)

# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = summary_ordered$KO) +
  scale_fill_manual(
    values = c("#3294DDFF", "#CB64C0FF"),
    labels = c("Indels", "Substitutions")
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
    x = "Genotype",
    y = "Mean mutation rate (muts/generation)"
  )

print(p)

# PER SAMPLE #

# Define a consistent dodge position matching the bar width
dodge <- position_dodge(width = 0.8)

# Plot with wider bars and aligned elements
p <- ggplot(final_df, aes(x = sample, y = value, fill = mut_type)) +
  geom_bar(stat = "identity", position = dodge, width = 0.8)

# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = final_df$sample) +
  scale_fill_manual(
    values = c("#3294DDFF", "#CB64C0FF"),
    labels = c("Indels", "Substitutions")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, size = 12, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.x = element_text(size = 17, vjust = 2.5),
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
    y = "Mutation rate (muts/generation)"
  )

print(p)