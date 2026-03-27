# analyse Ensembl VEP results for ID for all samples

library(tidyverse)
library(data.table)
library(paletteer)
library(colorspace)
library(hues)

# set the paths
path <- "/Volumes/NO NAME/ensembl_vep_results_denovo/ID"
files <- list.files(path = path, pattern = "\\.txt$", full.names = TRUE)

# read in the files
data <- lapply(files, function(file) {
  read.delim(file, header = TRUE, sep = "\t")
})
names(data) <- sub("\\.txt$", "", basename(files))
samples <- names(data)

# add a sample column
data <- lapply(seq_along(data), function(x) {
  df <- data[[x]]        # extract the data frame
  df$Sample <- samples[x]
  df             
})
names(data) <- sub("\\.txt$", "", basename(files))

# stack all samples together
data_stacked <- bind_rows(data, .id = "Sample")

# keep only relevant columns
cols_to_keep <- c("Location", "Allele", "Consequence", "IMPACT", "SYMBOL", "Gene", "Feature_type", "Feature", "BIOTYPE", "Existing_variation", "SIFT", "PolyPhen", "CLIN_SIG", "PUBMED", "Sample")
data_stacked <- data_stacked[ , cols_to_keep]

# list all the consequence types
consequences <- unique(data_stacked$Consequence)
# simplify complex categories
lookup <- c(
  "intron_variant,non_coding_transcript_variant" = "non_coding_transcript_variant",
  "intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "3_prime_UTR_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_polypyrimidine_tract_variant,intron_variant" = "splice_region_variant",
  "splice_polypyrimidine_tract_variant,intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_polypyrimidine_tract_variant,intron_variant,non_coding_transcript_variant" = "splice_region_variant",
  "splice_region_variant,splice_polypyrimidine_tract_variant,intron_variant" = "splice_region_variant",
  "splice_region_variant,splice_polypyrimidine_tract_variant,intron_variant,non_coding_transcript_variant" = "splice_region_variant",
  "stop_gained,NMD_transcript_variant" = "stop_gained",
  "splice_donor_region_variant,intron_variant,non_coding_transcript_variant" = "splice_region_variant",
  "splice_region_variant,3_prime_UTR_variant" = "3_prime_UTR_variant",
  "splice_region_variant,intron_variant,non_coding_transcript_variant" = "splice_region_variant",
  "splice_donor_region_variant,intron_variant" = "splice_region_variant",
  "splice_region_variant,5_prime_UTR_variant" = "5_prime_UTR_variant",
  "splice_donor_region_variant,intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_donor_5th_base_variant,intron_variant,non_coding_transcript_variant" = "splice_region_variant",
  "splice_donor_variant,NMD_transcript_variant" = "splice_donor_variant",
  "missense_variant,splice_region_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_region_variant,3_prime_UTR_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "stop_gained,splice_region_variant" = "stop_gained",
  "splice_acceptor_variant,NMD_transcript_variant" = "splice_acceptor_variant",
  "stop_gained,splice_region_variant,NMD_transcript_variant" = "stop_gained",
  "start_lost,NMD_transcript_variant" = "start_lost",
  "non_coding_transcript_exon_variant" = "non_coding_transcript_variant",
  "splice_region_variant,intron_variant" = "splice_region_variant",
  "splice_region_variant,intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "5_prime_UTR_variant,NMD_transcript_variant" = "5_prime_UTR_variant",
  "splice_region_variant,non_coding_transcript_exon_variant" = "splice_region_variant",
  "synonymous_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_acceptor_variant,non_coding_transcript_variant" = "splice_acceptor_variant",
  "missense_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_donor_variant,non_coding_transcript_variant" = "splice_donor_variant",
  "splice_region_variant,synonymous_variant" = "splice_region_variant",
  "incomplete_terminal_codon_variant,coding_sequence_variant" = "incomplete_terminal_codon_variant",
  "missense_variant,splice_region_variant" = "splice_region_variant",
  "splice_donor_5th_base_variant,intron_variant" = "splice_region_variant",
  "splice_donor_5th_base_variant,intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "splice_region_variant,splice_polypyrimidine_tract_variant,intron_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "stop_lost,NMD_transcript_variant" = "stop_lost",
  "splice_region_variant,synonymous_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "frameshift_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "start_lost,inframe_deletion,start_retained_variant" = "start_lost",
  "splice_donor_variant,splice_donor_5th_base_variant,non_coding_transcript_exon_variant,intron_variant" = "start_donor_variant",
  "splice_region_variant,5_prime_UTR_variant,NMD_transcript_variant" = "NMD_transcript_variant",
  "frameshift_variant,splice_region_variant" = "frameshift_variant",
  "frameshift_variant,stop_lost,NMD_transcript_variant" = "frameshift_variant",
  "inframe_deletion,NMD_transcript_variant" = "NMD_transcript_variant",
  "frameshift_variant,splice_region_variant,NMD_transcript_variant" = "frameshift_variant",
  "frameshift_variant,stop_lost" = "frameshift_variant"
)

data_stacked$Consequence <-
  ifelse(data_stacked$Consequence %in% names(lookup),
         lookup[data_stacked$Consequence],
         data_stacked$Consequence)  

# reorder samples
low_mutators <- c("HC1", "HC2", "C1-2", "F7-2", "F10-1", "F10-2", "H2-1", "H2-2")
hypermutators <- c("D6B", "A2-1", "A2-2", "F7-1", "C1-1", "C12-1", "C12-2", "C10_1", "C7_1", "D4_1", "D6_1", "E5_1", "E5_2", "E8_1", "E8_2")
sample_order <- c(low_mutators, hypermutators)

data_stacked$Sample <- factor(data_stacked$Sample, levels = sample_order)
data_stacked <- data_stacked[order(data_stacked$Sample), ]

# add genotype information
genotype <- c("WT", "WT", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MSH3-/-", "MBD4-/-", "MBD4-/-", "MLH1-/- MSH6-/- (sim)", "MLH1-/-", "MLH1-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH6-/-", "MLH1-/- MSH3-/-", "MLH1-/- MSH3-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-", "MLH1-/- MBD4-/-")
lookup_genotype <- data.frame(sample = sample_order, genotype = genotype)
data_stacked$Genotype <- lookup_genotype$genotype[match(data_stacked$Sample, lookup_genotype$sample)]

# calculate the counts of each consequence type per genotype
counts <- table(data_stacked$Consequence, data_stacked$Genotype) # returns contingency table
counts_norm <- prop.table(counts, margin = 2)
# convert to proportions
counts_df <- as.data.frame.matrix(counts)
counts_df <- counts_df[ , unique(genotype)]
counts_norm_df <- as.data.frame.matrix(counts_norm)
counts_norm_df <- counts_norm_df[ , unique(genotype)]
# convert proportions to %
num_cols <- sapply(counts_norm_df, is.numeric)
counts_norm_df[num_cols] <- round(counts_norm_df[num_cols] * 100, 2)

### PLOT AS STACKED BAR CHART ###
# create a colour palette
vaporwave_palette <- paletteer_d("vapoRwave::vapoRwave")
darkening_factor <- 0.3
darker_vaporwave <- darken(vaporwave_palette, amount = darkening_factor) # creating a shadow palette for vaporwave (30% darker copies of colours)
doubled_palette <- c(darker_vaporwave, vaporwave_palette)

# pivot longer
counts_norm_df_long <- counts_norm_df %>%
  rownames_to_column(var = "Consequence") # have to convert row names to a column, otherwise pivot_longer will erase them

counts_norm_df_long <- counts_norm_df_long %>%
  pivot_longer(
    cols = -Consequence,
    names_to = "Genotype",
    values_to = "Proportion"
  )

# ensuring correct sample order on the plot
# unless specified, ggplot converts character vector to a factor and orders values alphabetically
counts_norm_df_long$Genotype <- factor(counts_norm_df_long$Genotype, levels = unique(counts_norm_df_long$Genotype))

# plot all consequence types
bar_chart <- ggplot(counts_norm_df_long, aes(x = Genotype, y = Proportion, fill = Consequence)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = doubled_palette) +
  guides(fill = guide_legend(ncol = 1)) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18, margin = margin(t = 30)),
    axis.text.x = element_text(size = 10, angle = -45, vjust = 1),
    axis.text.y = element_text(size = 10),
    legend.title = element_text(size = 14),
    legend.text  = element_text(size = 12),
    legend.position="right") +
  labs(
    x = "Genotype",
    y = "Proportion of ID consequence types"
  )

# add the line to separate hypermutators and low-mutators
target_gen <- "MBD4-/-" 
x_axis_levels <- levels(counts_norm_df_long$Genotype) # will only work if the Samples column is a factor
index_of_target <- which(x_axis_levels == target_gen)
x_line_position <- index_of_target + 0.5

bar_chart <- bar_chart + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)
print(bar_chart)

# plot the minor consequences only
main_consequences <- c("downstream_gene_variant", "intergenic_variant", "intron_variant", "NMD_transcript_variant", "non_coding_transcript_variant", "upstream_gene_variant")
counts_minor_norm_df <- counts_norm_df[!rownames(counts_norm_df) %in% main_consequences, ]

counts_minor_norm_df_long <- counts_minor_norm_df %>%
  rownames_to_column(var = "Consequence") # have to convert row names to a column, otherwise pivot_longer will erase them

counts_minor_norm_df_long <- counts_minor_norm_df_long %>%
  pivot_longer(
    cols = -Consequence,
    names_to = "Genotype",
    values_to = "Proportion"
  )

counts_minor_norm_df_long$Genotype <- factor(counts_minor_norm_df_long$Genotype, levels = unique(counts_minor_norm_df_long$Genotype))

bar_chart_minor <- ggplot(counts_minor_norm_df_long, aes(x = Genotype, y = Proportion, fill = Consequence)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = doubled_palette) +
  guides(fill = guide_legend(ncol = 1)) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18, margin = margin(t = 30)),
    axis.text.x = element_text(size = 10, angle = -45, vjust = 1),
    axis.text.y = element_text(size = 10),
    legend.title = element_text(size = 14),
    legend.text  = element_text(size = 12),
    legend.position="right") +
  labs(
    x = "Genotype",
    y = "Proportion of ID consequence types"
  )

bar_chart_minor <- bar_chart_minor + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)
print(bar_chart_minor)

# plot the major consequences only
counts_major_norm_df <- counts_norm_df[rownames(counts_norm_df) %in% main_consequences, ]

counts_major_norm_df_long <- counts_major_norm_df %>%
  rownames_to_column(var = "Consequence") # have to convert row names to a column, otherwise pivot_longer will erase them

counts_major_norm_df_long <- counts_major_norm_df_long %>%
  pivot_longer(
    cols = -Consequence,
    names_to = "Genotype",
    values_to = "Proportion"
  )

counts_major_norm_df_long$Genotype <- factor(counts_major_norm_df_long$Genotype, levels = unique(counts_major_norm_df_long$Genotype))

bar_chart_major <- ggplot(counts_major_norm_df_long, aes(x = Genotype, y = Proportion, fill = Consequence)) +
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
    x = "Genotype",
    y = "Proportion of SBS consequence types"
  )

bar_chart_major <- bar_chart_major + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)
print(bar_chart_major)

### PLOT IMPACT ###
# calculate the counts of each impact value per genotype
impact_counts <- table(data_stacked$IMPACT, data_stacked$Genotype) # returns contingency table
impact_counts_norm <- prop.table(impact_counts, margin = 2)
# convert to proportions, order
impact_counts_df <- as.data.frame.matrix(impact_counts)
impact_counts_df <- impact_counts_df[ , unique(genotype)]
impact_counts_norm_df <- as.data.frame.matrix(impact_counts_norm)
impact_counts_norm_df <- impact_counts_norm_df[ , unique(genotype)]
# convert proportions to %
num_cols <- sapply(impact_counts_norm_df, is.numeric)
impact_counts_norm_df[num_cols] <- round(impact_counts_norm_df[num_cols] * 100, 2)

# plot as stacked bar chart
impact_counts_norm_df_long <- impact_counts_norm_df %>%
  rownames_to_column(var = "Impact") # have to convert row names to a column, otherwise pivot_longer will erase them

impact_counts_norm_df_long <- impact_counts_norm_df_long %>%
  pivot_longer(
    cols = -Impact,
    names_to = "Genotype",
    values_to = "Proportion"
  )

impact_counts_norm_df_long$Genotype <- factor(impact_counts_norm_df_long$Genotype, levels = unique(impact_counts_norm_df_long$Genotype))

impact_bar_chart <- ggplot(impact_counts_norm_df_long, aes(x = Genotype, y = Proportion, fill = Impact)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = doubled_palette) +
  theme(
    panel.grid.minor.x = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.border = element_rect(colour = "black", fill = NA),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18, margin = margin(t = 30)),
    axis.text.x = element_text(size = 10, angle = -45, vjust = 1),
    axis.text.y = element_text(size = 10),
    legend.title = element_text(size = 14),
    legend.text  = element_text(size = 12),
    legend.position="right") +
  labs(
    x = "Genotype",
    y = "Proportion of ID with each impact type"
  )

impact_bar_chart <- impact_bar_chart + geom_vline(
  xintercept = x_line_position,
  linetype = "dashed", # Sets the line style to dashed
  color = "black",       # Sets the line color
  linewidth = 0.7      # Sets the thickness
)
print(impact_bar_chart)

### extract genes with pathogenic/likely pathogenic variants
pathogenic_list <- c("likely_pathogenic", "uncertain_significance,pathogenic,likely_pathogenic", "pathogenic", "pathogenic,likely_pathogenic", "likely_pathogenic,uncertain_significance", "uncertain_significance,pathogenic", "pathogenic,pathogenic/likely_pathogenic,likely_pathogenic")
pathogenic <- data_stacked[data_stacked$CLIN_SIG %in% pathogenic_list, ]
path_genes <- unique(pathogenic$SYMBOL)
clinvar_id <- unique(pathogenic$Existing_variation)
