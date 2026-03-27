# plotting SBS and ID counts from Gene as bar charts 

# loading libraries
library(paletteer)
library(tidyverse)
library(data.table)

# loading mutation data
subs_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)
ids_denovo <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)

#mut_rate <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mut_rate_unfilt.csv", sep = ",", header=T)

# remove MLH1-A6-PC
subs_denovo <- subs_denovo[subs_denovo$Sample != "MLH1-A6-PC", ]
ids_denovo <- ids_denovo[ids_denovo$Sample != "MLH1-A6-PC", ]

sample_ids <- unlist(unique(subs_denovo$Sample))
KOlist <- sapply(sample_ids, function(sample) {
  unique(subs_denovo$KO[subs_denovo$Sample == sample])
})

# subsetting the mutation rate table for the key columns
#mut_rate_subset <- mut_rate[, c(1:2, 8:9)]

# count the number of subs per sample (number of rows)
sub_counts <- sapply(sample_ids, function(sample) {
  sum(subs_denovo$Sample==sample)
})
# count the number of indels per sample (number of rows)
id_counts <- sapply(sample_ids, function(sample) {
  sum(ids_denovo$Sample==sample)
})

# joining both mutation types
df_joint <- data.frame(Sample=sample_ids, KO=KOlist, Substitutions=sub_counts, Indels=id_counts)
print(df_joint)
# melting the df to plot a bar chart
final_df <- pivot_longer(df_joint, cols = 3:4, names_to = "mut_type", values_to = "count")
print(final_df)

# generating summary statistics
all_good_summary <- final_df %>%
  group_by(KO, mut_type) %>%
  summarise(
    NChild = length(count),
    mean = mean(count),
    sd = sd(count),
    .groups = "drop"
  )
all_good_summary[is.na(all_good_summary)] <- 0 # replace NAs with zeroes

# adding low and high values for error bars
all_good_summary <- all_good_summary %>%
  mutate(
    ymin = mean - sd,
    ymax = mean + sd
  )

# order the rows
all_good_summary <- all_good_summary[c(17:18, 3:4, 15:16, 13:14, 1:2, 9:12, 7:8, 5:6) , ]

### PLOTTING ###

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart (chatgpt adjusted code)
# Define a consistent dodge position matching the bar width
dodge <- position_dodge(width = 0.7)

## GENOTYPE ANALYSIS ##

# Plot with wider bars and aligned elements
p <- ggplot(all_good_summary, aes(x = KO, y = mean, fill = mut_type)) +
  geom_bar(stat = "identity", position = dodge, width = 0.7) +
  geom_errorbar(aes(ymin = ymin, ymax = ymax),
                width = 0.3,
                position = position_dodge(width = 0.9)) +
  geom_jitter(
    data = final_df,
    aes(x = KO, y = count),
    position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.9),
    size = 1.5,
    show.legend = FALSE
  )
  
# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = all_good_summary$KO) +
  scale_fill_manual(
    #values = c("#3294DDFF", "#75FB8AFF", "#CB64C0FF", "#FD6598FF"),
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
    y = "Mean mutation count"
  )

print(p)

## SAMPLE ANALYSIS ##

dodge2 <- position_dodge(width = 0.7)

# Plot with wider bars and aligned elements
q <- ggplot(final_df, aes(x = sample, y = count, fill = mut_type)) +
  geom_bar(stat = "identity", position = dodge2, width = 0.7)

# Continue with rest of styling
q <- q +
  scale_x_discrete(limits = final_df$sample) +
  scale_fill_manual(
    #values = c("#3294DDFF", "#75FB8AFF", "#CB64C0FF", "#FD6598FF"),
    values = c("#3294DDFF", "#CB64C0FF"),
    labels = c("Indels", "Substitutions")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, size = 12, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.x = element_text(size = 17, vjust = 3),
    axis.title.y = element_text(size = 17, vjust = 2.3),
    plot.title = element_text(size = 10),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    legend.position = c(0.10, 0.85),
    legend.title = element_blank(),
    legend.text = element_text(size = 12),
    legend.key.size = unit(8, "mm")
  ) +
  labs(
    x = "Sample",
    y = "Mean mutation rate (muts/generation)"
  )

print(q)


### plot separately for WT, MSH3 and MBD4 KO with lower scale ###

summary_subset <- all_good_summary[all_good_summary$KO %in% c("WT", "MSH3-/-", "MBD4-/-"), ]
summary_subset <- summary_subset[summary_subset$mut_type == "Indels", ]

# Plot with wider bars and aligned elements

p <- ggplot(summary_subset, aes(x = KO, y = mean, fill = mut_type)) +
  geom_bar(stat = "identity", position = dodge, width = 0.7) +
  geom_errorbar(aes(ymin = ymin, ymax = ymax),
                width = 0.3,
                position = position_dodge(width = 0.9)) +
  geom_jitter(
    data = final_df,
    aes(x = KO, y = count),
    inherit.aes = FALSE,
    position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.9),
    size = 1.5,
    show.legend = FALSE)

# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = summary_subset$KO) +
  scale_fill_manual(
    #values = c("#3294DDFF", "#75FB8AFF", "#CB64C0FF", "#FD6598FF"),
    values = c("#3294DDFF"),
    labels = c("Indels")
  ) +
  coord_cartesian(ylim = c(0, 200)) +
  theme(
    axis.text.x = element_text(angle = 45, size = 12, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.x = element_text(size = 17, vjust = 3),
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
    y = "Mean mutation count"
  )

print(p)


