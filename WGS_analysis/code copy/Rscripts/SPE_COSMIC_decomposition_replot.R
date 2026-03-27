### reformat the SigProfiler Extractor plots for decomposed COSMIC signatures ###

library(tidyverse)
library(paletteer)
library(colorspace)

# read in the data
SBS_decomp_activities <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_extractor_output/SBS/Suggested_Solution/COSMIC_SBS96_Decomposed_Solution/Activities/COSMIC_SBS96_Activities.txt", delim = "\t")
ID_decomp_activities <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_extractor_output/ID/Suggested_Solution/COSMIC_ID83_Decomposed_Solution/Activities/COSMIC_ID83_Activities.txt", delim = "\t")

# remove MLH1-A6-PC from both
SBS_decomp_activities <- SBS_decomp_activities[SBS_decomp_activities$Samples != "MLH1-A6-PC", ]
ID_decomp_activities <- ID_decomp_activities[ID_decomp_activities$Samples != "MLH1-A6-PC", ]

# convert activities to proportions
SBS_decomp_activities$sum <- rowSums(SBS_decomp_activities[, 2:7])
SBS_decomp_activities_norm <- SBS_decomp_activities[, 2:7]/SBS_decomp_activities$sum
SBS_decomp_activities_norm$Samples <- SBS_decomp_activities$Samples

ID_decomp_activities$sum <- rowSums(ID_decomp_activities[, 2:7])
ID_decomp_activities_norm <- ID_decomp_activities[, 2:7]/ID_decomp_activities$sum
ID_decomp_activities_norm$Samples <- ID_decomp_activities$Samples

# reorder samples
low_mutators <- c("HC1", "HC2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2")
hypermutators <- c("D6B", "A2-1", "A2-2", "F7-1", "C1-1", "C12-1", "C12-2", "C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
sample_order <- c(low_mutators, hypermutators)

SBS_decomp_activities_norm$Samples <- factor(SBS_decomp_activities_norm$Samples, levels = sample_order)
SBS_norm_ordered <- SBS_decomp_activities_norm[order(SBS_decomp_activities_norm$Samples), ]

ID_decomp_activities_norm$Samples <- factor(ID_decomp_activities_norm$Samples, levels = sample_order)
ID_norm_ordered <- ID_decomp_activities_norm[order(ID_decomp_activities_norm$Samples), ]

# plot
# download the colours
cross_palette <- paletteer_d("MetBrewer::Cross")
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

#pivot longer (necessary for a stacked bar chart)
SBS_norm_ordered_long <- pivot_longer(SBS_norm_ordered, cols = 1:6, names_to = "Signature", values_to = "Proportion")
ID_norm_ordered_long <- pivot_longer(ID_norm_ordered, cols = 1:6, names_to = "Signature", values_to = "Proportion")

## SBS
p <- ggplot(SBS_norm_ordered_long, aes(x = Samples, y = Proportion, fill = Signature)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = neon_palette) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
  ) +
  labs(
    x = "Sample",
    y = "Proportion of mutations in signature"
  )

# adding a dashed line to separate mutators and non-mutators
target_sample <- "H2-2" 
x_axis_levels <- levels(SBS_norm_ordered_long$Samples) # will only work if the Samples column is a factor
index_of_target <- which(x_axis_levels == target_sample)
x_line_position <- index_of_target + 0.5

p <- p + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)

print(p)

## indels
p <- ggplot(ID_norm_ordered_long, aes(x = Samples, y = Proportion, fill = Signature)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = neon_palette) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
  ) +
  labs(
    x = "Sample",
    y = "Proportion of mutations in signature"
  )

# adding a dashed line to separate mutators and non-mutators
target_sample <- "H2-2" 
x_axis_levels <- levels(ID_norm_ordered_long$Samples) # will only work if the Samples column is a factor
index_of_target <- which(x_axis_levels == target_sample)
x_line_position <- index_of_target + 0.5

p <- p + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)

print(p)


