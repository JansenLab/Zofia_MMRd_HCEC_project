# correlating signature activity with the number of cell divisions 
# for signatures that show a spread on the TMB graph: 
# SBS1, SBS5, SBS18, SBS14, SBS44, SBS20, SBS26, SBS40c
# ID1, ID2, ID9

library(paletteer)
library(tidyverse)
library(data.table)
library(ggpubr)

# read in the data
sbs_activity <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS/Activities/Assignment_Solution_Activities.txt", sep = "\t", header = T)
id_activity <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID/Activities/Assignment_Solution_Activities.txt", sep = "\t", header = T)
cell_div <- read_csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/mut_rate_v2.csv")

# clean the data
sbs_activity_clean <- sbs_activity[1:23, c("Samples", "SBS1", "SBS5", "SBS18", "SBS14", "SBS44", "SBS20", "SBS26", "SBS40c")]
id_activity_clean <- id_activity[1:23, c("Samples", "ID1", "ID2", "ID9")]

cell_div_only <- cell_div[ , c("sample", "number_of_divisions")]
# reordering samples to match the signature files
sample_order <- unlist(sbs_activity_clean$Samples)
cell_div_only <- cell_div_only[match(sample_order, cell_div_only$sample), ] # using base R; can also be done with dplyr mutate and arrange

# prepare the final data frame
activity_joint <- data.frame(sbs_activity_clean, id_activity_clean[ , 2:4], cell_div_only$number_of_divisions)
# pivot_longer to plot multiple correlations on one graph
long_data <- activity_joint %>%
  pivot_longer(cols = 2:12, names_to = "Signature", values_to = "value")

# Plot with correlation line
p <- ggplot(long_data, aes(x = long_data[[2]], y = value, color = Signature)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Number of cell divisions", y = "Signature activity") +
  stat_cor(aes(group = Signature), position = position_nudge(y = 0.1)) +
  theme(
    axis.title.x = element_text(size=12),
    axis.title.y = element_text(size=12)
  ) +
  theme_minimal()

print(p)




