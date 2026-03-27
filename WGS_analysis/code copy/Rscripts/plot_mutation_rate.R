### plot mutation rate bar chart ###

# loading libraries
library(paletteer)
library(tidyverse)
library(data.table)

# loading mutation data
mut_rate <- read_csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mut_rate_time_as_MMRd.csv", col_names = TRUE)
# subset for only the columns necessary for plotting
mut_rate_filt <- mut_rate[ , c(1:2, 8:9)]
# pivot longer for plotting
final_df <- pivot_longer(mut_rate_filt, cols = 3:4, names_to = "mut_rate_type", values_to = "count")

# calculate stats
all_good_summary <- final_df %>%
  group_by(KO, mut_rate_type) %>%
  summarise(
    NChild = length(count),
    mean = mean(count),
    sd = sd(count),
    .groups = "drop"
  )
all_good_summary[is.na(all_good_summary)] <- 0 # replace NAs with zeroes

# order
all_good_summary <- all_good_summary[c(17:18, 3:4, 15:16, 13:14, 1:2, 9:12, 7:8, 5:6) , ]

# calculate min and max values
all_good_summary <- all_good_summary %>%
  mutate(
    ymin = mean - sd,
    ymax = mean + sd
  )

### PLOTTING ###

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart (chatgpt adjusted code)
# Define a consistent dodge position matching the bar width
dodge <- position_dodge(width = 0.7)

## GENOTYPE ANALYSIS ##

# Plot with wider bars and aligned elements
p <- ggplot(all_good_summary, aes(x = KO, y = mean, fill = mut_rate_type)) +
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
    y = "Mean mutation rate"
  )

print(p)

