### replotting the bar chart of signature activity detected with SPA ###

library(tidyverse)
library(paletteer)
library(colorspace)
library(hues)
library(viridis)

# read in the data
SBS_activities <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS/Activities/Assignment_Solution_Activities.txt", delim = "\t")
ID_activities <- read_delim("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID/Activities/Assignment_Solution_Activities.txt", delim = "\t")

# remove MLH1-A6-PC from both
SBS_activities <- SBS_activities[SBS_activities$Samples != "MLH1-A6-PC", ]
ID_activities <- ID_activities[ID_activities$Samples != "MLH1-A6-PC", ]

# convert activities to proportions
SBS_activities$sum <- rowSums(SBS_activities[, 2:ncol(SBS_activities)])
SBS_activities_norm <- SBS_activities[, 2:ncol(SBS_activities)]/SBS_activities$sum
SBS_activities_norm$Samples <- SBS_activities$Samples

ID_activities$sum <- rowSums(ID_activities[, 2:ncol(ID_activities)])
ID_activities_norm <- ID_activities[, 2:ncol(ID_activities)]/ID_activities$sum
ID_activities_norm$Samples <- ID_activities$Samples

# reorder samples
low_mutators <- c("HC1", "HC2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2")
hypermutators <- c("D6B", "A2-1", "A2-2", "F7-1", "C1-1", "C12-1", "C12-2", "C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
sample_order <- c(low_mutators, hypermutators)

SBS_activities_norm$Samples <- factor(SBS_activities_norm$Samples, levels = sample_order)
SBS_norm_ordered <- SBS_activities_norm[order(SBS_activities_norm$Samples), ]

ID_activities_norm$Samples <- factor(ID_activities_norm$Samples, levels = sample_order)
ID_norm_ordered <- ID_activities_norm[order(ID_activities_norm$Samples), ]

### plot SBS
# find out SBS signatures with no exposure in my dataset
cols_to_sum <- 1 : (ncol(SBS_norm_ordered) - 2)
sum_values <- colSums(SBS_norm_ordered[ , cols_to_sum])
sum_row_df <- as.data.frame(t(sum_values)) # convert to df
sum_row_df$sum <- "colSum" # adding new columns to make the format match SBS_norm_ordered
sum_row_df$Samples <- "all"
SBS_norm_ordered <- rbind(SBS_norm_ordered, sum_row_df) # attach the colSum values to the original df

zero_exp_sigs <- (SBS_norm_ordered[24, ] == 0) # creating a logical vector to act as a filter
zero_cols_names <- names(SBS_norm_ordered)[zero_exp_sigs]

# filter out signatures with zero exp
cols_to_keep <- !(names(SBS_norm_ordered) %in% zero_cols_names)
SBS_filtered <- SBS_norm_ordered[1:23, cols_to_keep] # remove the colSums row, not needed anymore

# adding the genotype column
genotype <- c("WT", "WT", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "MLH1-/-\nMSH6-/-(sim KO)", "MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-") 
SBS_filtered$genotype <- genotype

# creating the colour palette
vaporwave_palette <- paletteer_d("vapoRwave::vapoRwave")

darkening_factor <- 0.3
darker_vaporwave <- darken(vaporwave_palette, amount = darkening_factor) # creating a shadow palette for vaporwave (30% darker copies of colours)
doubled_palette <- c(darker_vaporwave, vaporwave_palette)

# create a horizontal line annotating genotypes
# calculating coordinate positions for the line
genotype_summary <- SBS_filtered %>%
  # Ensure Sample is a factor with the correct plot order
  mutate(Samples = factor(Samples, levels = unique(SBS_filtered$Samples))) %>%
  group_by(genotype) %>%
  summarise(
    # Find the index of the first sample (start position)
    start_pos = min(as.numeric(Samples)),
    # Find the index of the last sample (end position)
    end_pos = max(as.numeric(Samples)),
    # Calculate the center for the label
    center_pos = (start_pos + end_pos) / 2,
    .groups = 'drop'
  ) %>%
  mutate(
    # The rect position is 0.5 units beyond the start/end samples
    rect_xmin = start_pos - 0.5,
    rect_xmax = end_pos + 0.5
  )

#pivot longer (necessary for a stacked bar chart)
SBS_norm_ordered_long <- pivot_longer(SBS_filtered, cols = 1:20, names_to = "Signature", values_to = "Proportion")

## SBS
p_SBS <- ggplot(SBS_norm_ordered_long, aes(x = Samples, y = Proportion, fill = Signature)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = doubled_palette) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    #panel.border = element_rect(colour = "black", fill = NA),
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

p_SBS <- p_SBS + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)

# adding the vertical line with genotype information below
p_SBS <- p_SBS + geom_segment(
    data = genotype_summary,
    aes(
      x = rect_xmin,
      xend = rect_xmax,
      y = -0.05,    # Start Y position of the track
      yend = -0.05,    # End Y position of the track
      color = genotype  # Colour the track by Genotype
    ),
    inherit.aes = FALSE, # Crucial! Do not inherit the Sample/Proportion aesthetics
    linewidth = 1,
    show.legend = FALSE
  ) +
  
  # 2. Add the genotype labels
  geom_text(
    data = genotype_summary,
    aes(
      x = center_pos,
      y = -0.07,        # Y position (center of the track)
      label = genotype
    ),
    inherit.aes = FALSE, # Crucial!
    size = 4,
    #fontface = "bold",
    #angle = -45,
    hjust = 0
  ) 

print(p_SBS)

## plot indels
# find out indel signatures with no exposure in my dataset
cols_to_sum <- 1 : (ncol(ID_norm_ordered) - 2)
sum_values <- colSums(ID_norm_ordered[ , cols_to_sum])
sum_row_id_df <- as.data.frame(t(sum_values)) # convert to df
sum_row_id_df$sum <- "colSum" # adding new columns to make the format match SBS_norm_ordered
sum_row_id_df$Samples <- "all"
ID_norm_ordered <- rbind(ID_norm_ordered, sum_row_id_df) # attach the colSum values to the original df

zero_exp_sigs <- (ID_norm_ordered[24, ] == 0) # creating a logical vector to act as a filter
zero_cols_names <- names(ID_norm_ordered)[zero_exp_sigs]

# filter out signatures with zero exp
cols_to_keep <- !(names(ID_norm_ordered) %in% zero_cols_names)
ID_filtered <- ID_norm_ordered[1:23, cols_to_keep] # remove the colSums row, not needed anymore
ID_norm_ordered_long <- pivot_longer(ID_filtered, cols = 1:7, names_to = "Signature", values_to = "Proportion")

p <- ggplot(ID_norm_ordered_long, aes(x = Samples, y = Proportion, fill = Signature)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = doubled_palette) +
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

# round the values in filtered dfs to make them more readable
SBS_rounded <- as.data.frame(
  lapply(SBS_filtered[, 1:20], round, digits = 2)
)
SBS_rounded$Samples <- SBS_filtered$Samples

ID_rounded <- as.data.frame(
  lapply(ID_filtered[, 1:8], round, digits = 2)
)
ID_rounded$Samples <- ID_filtered$Samples

# save the simplified activities tables
write_csv(SBS_rounded, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS_activities_simplified.csv")
write_csv(ID_rounded, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID_activities_simplified.csv")

# also save the exact activity values
write_csv(SBS_filtered, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS_activities.csv")
write_csv(ID_filtered, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID_activities.csv")

