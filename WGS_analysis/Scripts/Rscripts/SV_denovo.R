### check if any SV from MLH1-A6-PC overlap with the SVs in other samples ###

library(paletteer)
library(tidyverse)
library(data.table)

# load in the original data from Gene
SV <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/variants_GeneKoh_WGS_batch1_30x/combined_bedpe.txt", sep = "\t", header = T)
# remove the A6 clones
SV <- SV[!(SV$sample %in% c("A6-1", "A6-2", "A5A", "A5A,HCEC-MC", "A5B", "A6A", "A6B", "B7A", "B7B", "B8A", "B8B", "C7A", "C7B", "C8A", "C8B")), ]
# I assume any variant that has "HCEC-MC" in the name is also present in the normal
# remove these variants
SV$sample <- sub(",HCEC-MC$", "", SV$sample)
SV <- SV[ , 1:12]

# subtracting background SV
background <- SV[SV$sample == "MLH1-A6-PC", ]
SV_private <- setdiff(SV, background)

# count the number of each type of SV per sample
SV_counts_denovo <- lapply(sample_ids, function(sample) {
  dels <- sum(SV_private$sample == sample & SV_private$svclass == "deletion")
  td   <- sum(SV_private$sample == sample & SV_private$svclass == "tandem-duplication")
  tl   <- sum(SV_private$sample == sample & SV_private$svclass == "translocation")
  inv  <- sum(SV_private$sample == sample & SV_private$svclass == "inversion")
  
  # Return a named vector for each sample
  return(data.frame(
    Sample = sample,
    Deletions = dels,
    TandemDuplications = td,
    Translocations = tl,
    Inversions = inv
  ))
})

# Combine all rows into one data frame
SV_counts_df <- as.data.frame(t(do.call(rbind, SV_counts)))
# save private SVs in a file
write_delim(SV_counts_df, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/SV_counts_denovo.csv", delim=",")


### plot private SV counts
SV_longer <- pivot_longer(SV_counts_df, cols = 3:6, names_to = "SV_type", values_to = "count")
SV_longer$count <- as.numeric(SV_longer$count)

SV_summary <- SV_longer %>%
  group_by(Genotype, SV_type) %>%
  summarise(
    NChild = length(count),
    mean = mean(count),
    sd = sd(count),
    .groups = "drop"
  )
SV_summary[is.na(SV_summary)] <- 0 # replace NAs with zeroes

SV_summary <- SV_summary[c(33:36, 5:8, 29:32, 25:28, 1:4, 17:20, 21:24, 13:16, 9:12), ]

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

