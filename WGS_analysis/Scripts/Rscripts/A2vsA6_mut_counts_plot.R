# plotting the difference in mutation counts between A2 and A6

library(paletteer)
library(tidyverse)
library(data.table)

# read in the data
muts <- read.csv("/Users/zofiapiszka/Library/CloudStorage/OneDrive-UniversityCollegeLondon/phd_docs/thesis/A6 and A2 comparison.csv")

# melt the muts df to fit the ggplot format
muts_melt <- pivot_longer(muts, cols = 2:3, names_to = "mut_type", values_to = "count")
print(muts_melt)

# download the colours
neon_palette <- paletteer::paletteer_d("PrettyCols::Neon")

# plot the bar chart (chatgpt adjusted code)

# Plot with wider bars and aligned elements
p <- ggplot(muts_melt, aes(x = Sample, y = count, fill = mut_type)) +
  geom_bar(stat = "identity", position = position_dodge(), width=0.5)

# Continue with rest of styling
p <- p +
  scale_x_discrete(limits = muts$Sample) +
  scale_fill_manual(
    values = c("#3294DDFF", "#CB64C0FF"),
    labels = c("Substitutions", "Indels")
  ) +
  theme(
    axis.text.x = element_text(angle = 45, size = 17, colour = "black", hjust = 0.9, vjust = 1),
    axis.text.y = element_text(size = 17, colour = "black"),
    axis.title.x = element_text(size = 20, vjust = 3.3),
    axis.title.y = element_text(size = 20, vjust = 2.3),
    plot.title = element_text(size = 10),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    legend.position = c(0.15, 0.85),
    legend.title = element_blank(),
    legend.text = element_text(size = 20),
    legend.key.size = unit(10, "mm")
  ) +
  labs(
    x = "Sample",
    y = "Mutation count"
  )

print(p)
