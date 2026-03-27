### plot SV per genotype ###

library(paletteer)
library(tidyverse)
library(data.table)

SV_counts <- read_csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/SV_counts.csv")
SV_counts$Genotype <- lookup$KO
SV_counts <- SV_counts[ , c(1, 6, 2:5)]

SV_longer <- pivot_longer(SV_counts, cols = 3:6, names_to = "SV_type", values_to = "count")

SV_summary <- SV_longer %>%
  group_by(Genotype, SV_type) %>%
  summarise(
    NChild = length(count),
    mean = mean(count),
    sd = sd(count),
    .groups = "drop"
  )
SV_summary[is.na(SV_summary)] <- 0 # replace NAs with zeroes

SV_summary <- SV_summary[c(37:40, 5:8, 33:36, 29:32, 1:4, 25:28, 17:20, 21:24, 13:16, 9:12), ]
write.csv(SV_summary, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/SV_counts_per_genotype.csv")


SV_summary <- SV_summary %>%
  mutate(
    ymin = mean - sd,
    ymax = mean + sd
  )
SV_summary[SV_summary < 0] <- 0

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart (chatgpt adjusted code)
# Plot with wider bars and aligned elements
p <- ggplot(SV_summary, aes(x = Genotype, y = mean, fill = SV_type)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.5), width = 0.5) +
  geom_jitter(
    data = SV_longer,
    aes(x = Genotype, y = count, fill=SV_type),
    position = position_jitterdodge(jitter.width = 0, dodge.width = 0.5),
    size = 1.5,
    show.legend = FALSE
  )
  
# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = unique(SV_summary$Genotype), expand = expansion(mult = c(0.05, 0.05))) +
  scale_fill_manual(
    values = c("#3294DDFF", "#75FB8AFF", "#CB64C0FF", "#FD6598FF"),
    labels = c("Deletions", "Tandem duplications", "Translocations", "Inversions")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, size = 12, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.x = element_text(size = 17, vjust = 4),
    axis.title.y = element_text(size = 17, vjust = 1),
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
    y = "SV count"
  )

print(p)
