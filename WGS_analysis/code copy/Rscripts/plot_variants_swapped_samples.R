library(ggplot2)
library(cowplot)
library(eulerr)
library(viridis)
library(dplyr)
library(purrr)

cloneList <- c("C1-1", "F7-1")

csvFile <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_HC_merged/shared_indels_per_clone/C1.1.F7.1_shared_indels.csv")
  
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_HC_merged/shared_indels_per_clone/C1.1.F7.1_shared_indels_VAF.pdf")

# VAF spectrum #
p1 <- ggplot() +
  geom_histogram(aes(x = csvFile$C1.1), bins = 100) +
  labs(title = "C1-1", x = "VAF", y = "count") +
  theme_light()

p2 <- ggplot() +
  geom_histogram(aes(x = csvFile$F7.1), bins = 100) +
  labs(title = "F7-1", x = "VAF", y = "count") +
  theme_light()

grid <- plot_grid(p1, p2, ncol = 2)
print(grid)

dev.off()

#  venn diagram #
num_plots <- 3
# Generate a list of viridis colors, with each plot potentially having 3 regions (A, B, A&B)
colors <- viridis(num_plots) 
  
names <- c("C1.2", "F7.2")
euler_data <- c(A = 1811, 
                  B = 1865, 
                  "A&B" = 252)
  
euler_graph <- euler(euler_data)
# Extract the specific colors for this plot
plot_colors <- colors
# calculates starting and ending index for the color subset from viridis palette for ith plot
alpha_values <- c(0.6, 0.3, 1)

plot(euler_graph, labels = names, quantities = TRUE, fills = list(fill = plot_colors, alpha = alpha_values))
