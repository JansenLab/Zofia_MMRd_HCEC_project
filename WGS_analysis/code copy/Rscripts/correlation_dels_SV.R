# calculating the correlation between deletion counts from Pindel and from BRASS #
# use the overall deletion count rather than de novo - I think the bedpe file reports overall BRASS counts

library(paletteer)
library(tidyverse)
library(data.table)
library(ggrepel)

# reading in the data
del_counts <- read_csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mutation_counts_combined.csv", col_names = TRUE)
del_counts <- del_counts[ , c(1:2,4)] # retaining only the relevant columns
SV_counts <- read

# prepare the data for the plot
plot_data <- data.frame(x = del_counts$id_count_all, y = SV_counts$Deletions, sample = del_counts$sample)

# Plot with correlation line
p <- ggplot(plot_data, aes(x = x, y = y)) +
  geom_point() +                                 # Scatter plot
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Best fit line
  geom_text_repel(aes(label = sample)) +
  theme_minimal() +
  labs(x = "Pindel deletions", y = "BRASS deletions") +
  theme(
    axis.title.x = element_text(size=12),
    axis.title.y = element_text(size=12)
  ) +
  annotate("text", 
           x = 70, y = 40,                  # Adjust coordinates as needed
           label = "Pearson coefficient: 0.734", 
           color = "black", size = 5, hjust = 0)

# Print the plot
print(p)

# Compute Pearson correlation
correlation <- cor.test(plot_data$x, plot_data$y, method = "pearson")
print(correlation)
