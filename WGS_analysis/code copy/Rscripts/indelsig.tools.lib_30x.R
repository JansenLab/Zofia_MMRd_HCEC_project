### running indelsig.tools.lib on my mutations catalogues ###

library(indelsig.tools.lib)
library(signature.tools.lib)
library(data.table)
library(tidyverse)
library(cosmicsig)
library(gridExtra)
library(reshape2)
library(pheatmap)
library(RColorBrewer)

# read in the data 
ids <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_denovo_merged.txt", sep = "\t", header = T)

# splitting the file into files per sample
split_list <- split(ids, ids$Sample)
sample_names <- names(split_list) # set sample names
colnames <- colnames(ids)

# save as separate tsv files
file_names <- sapply(seq_along(split_list), function(i) {
  # set the file names
  file_name <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_files_by_sample/", sample_names[i], ".txt")
  write.table(split_list[i], file_name, sep = "\t", col.names = colnames)
  
  return(file_name)
})

# tsv files - stripped down and renamed columns
ids_stripped <- ids[ , c(1:2, 4:5, 12)]
colnames_simple <- c("chr", "position", "REF", "ALT", "sample")
colnames(ids_stripped) <- colnames_simple
split_list_stripped <- split(ids_stripped, ids_stripped$sample)

file_names <- sapply(seq_along(split_list_stripped), function(i) {
  # set the file names
  file_name <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_files_by_sample_indelsig/", sample_names[i], ".txt")
  write.table(split_list_stripped[i], file_name, sep = "\t", col.names = colnames_simple)
  
  return(file_name)
})

### running indelsig ###

# indel segmentation
id_segmented <- lapply(split_list_stripped, function(sample) {
  seg <- indel_classifier89(sample, "hg38")
  return(seg)
})

# generating 89-channel catalogues
id_catalogues <- lapply(id_segmented, function(sample) {
  catalogue <- gen_catalogue89(sample, sample_col = 4)
  return(catalogue)
})

### plotting all samples in one pdf ### 

# Make a list to store all plots
p_all <- list()

# Loop through each catalogue and generate a plot for each
for (i in seq_along(id_catalogues)) {
  muts_basis <- id_catalogues[[i]]
  sample_name <- names(id_catalogues)[i]
  # Assuming each muts_basis is a data frame with one column
  p <- gen_plot_catalouge89_single_percentage(
    data.frame(Sample = muts_basis[, 1], IndelType = rownames(muts_basis)),
    3,
    sample_name
  )
  p_all[[i]] <- p
}

pdf(file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/indelsig.tools.lib/all_samples_indel_catalogue.pdf", width = 40, height = 15)
do.call("grid.arrange", c(p_all, ncol = 6, nrow = 4))
dev.off()

# plot indel catalogue - doesn't work, had to modify the original function
# plots <- lapply(id_catalogues, function(sample) {
#   print(dim(sample))
#   plots_indelsig_89ch(sample, rownum = 4, h = 15, w = 40, outputname = NULL)
# })

# modifying the original plots_indelsig_89ch function
# removing the subsetting of indel catalogue, adding some dimension checks
my_plots_indelsig_89ch <- function (muts_basis, rownum = 5, h = 15, w = 40, outputname)
{
  muts_basis2 <- muts_basis
  print(dim(muts_basis2))
  if (is.null(dim(muts_basis2)) || dim(muts_basis2)[2] == 0) {
    stop("No columns remaining after subsetting. Check your input.")
  }
  p_all <- list()
  for (i in 1:dim(muts_basis2)[2]) {
    # using my modified single_percentage function that converts freq to %
    p <- my_gen_plot_catalouge89_single_percentage(data.frame(Sample = muts_basis2[, i], IndelType = rownames(muts_basis2)), 3, names(muts_basis2)[i])
    p_all[[length(p_all) + 1]] <- p
  }
  filename <- paste0(outputname, ".pdf")
  grDevices::pdf(file = filename, onefile = TRUE, width = w,
                 height = h)
  do.call("grid.arrange", c(p_all, ncol = 6, nrow = rownum))
  grDevices::dev.off()
}

# plot the indel catalogues for each sample separately using my modified plotting function
plots <- lapply(id_catalogues, function(sample) {
  str(sample)
  print(dim(sample))
  my_plots_indelsig_89ch(sample, rownum = 1, h = 3, w = 40, outputname = paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/indelsig.tools.lib/", names(sample)))
})

### the code above miscalculates the % on the y axis (see my notes) ###
# amend the gen_plot_catalouge89_single_percentage function to convert the freq values to % #

my_gen_plot_catalouge89_single_percentage <- function (muts_basis, text_size, plot_title) 
{
  indel_type_4_figurelabel <- structure(list(IndelType = c("A[Ins(C):R0]A", 
                                                           "A[Ins(C):R0]T", "Ins(C):R(0,3)", "Ins(C):R(4,6)", "Ins(C):R(7,9)", 
                                                           "A[Ins(T):R(0,4)]A", "A[Ins(T):R(0,4)]C", "A[Ins(T):R(0,4)]G", 
                                                           "C[Ins(T):R(0,4)]A", "C[Ins(T):R(0,4)]C", "C[Ins(T):R(0,4)]G", 
                                                           "G[Ins(T):R(0,4)]A", "G[Ins(T):R(0,4)]C", "G[Ins(T):R(0,4)]G", 
                                                           "A[Ins(T):R(5,7)]A", "A[Ins(T):R(5,7)]C", "A[Ins(T):R(5,7)]G", 
                                                           "C[Ins(T):R(5,7)]A", "C[Ins(T):R(5,7)]C", "C[Ins(T):R(5,7)]G", 
                                                           "G[Ins(T):R(5,7)]A", "G[Ins(T):R(5,7)]C", "G[Ins(T):R(5,7)]G", 
                                                           "A[Ins(T):R(8,9)]A", "A[Ins(T):R(8,9)]C", "A[Ins(T):R(8,9)]G", 
                                                           "C[Ins(T):R(8,9)]A", "C[Ins(T):R(8,9)]C", "C[Ins(T):R(8,9)]G", 
                                                           "G[Ins(T):R(8,9)]A", "G[Ins(T):R(8,9)]C", "G[Ins(T):R(8,9)]G", 
                                                           "Ins(2,4):R0", "Ins(5,):R0", "Ins(2,4):R1", "Ins(5,):R1", 
                                                           "Ins(2,):R(2,4)", "Ins(2,):R(5,9)", "[Del(C):R1]A", "[Del(C):R1]T", 
                                                           "[Del(C):R2]A", "[Del(C):R2]T", "[Del(C):R3]A", "[Del(C):R3]T", 
                                                           "[Del(C):R(4,5)]A", "[Del(C):R(4,5)]T", "[Del(C):R(1,5)]G", 
                                                           "Del(C):R(6,9)", "A[Del(T):R(1,4)]A", "A[Del(T):R(1,4)]C", 
                                                           "A[Del(T):R(1,4)]G", "C[Del(T):R(1,4)]A", "C[Del(T):R(1,4)]C", 
                                                           "C[Del(T):R(1,4)]G", "G[Del(T):R(1,4)]A", "G[Del(T):R(1,4)]C", 
                                                           "G[Del(T):R(1,4)]G", "A[Del(T):R(5,7)]A", "A[Del(T):R(5,7)]C", 
                                                           "A[Del(T):R(5,7)]G", "C[Del(T):R(5,7)]A", "C[Del(T):R(5,7)]C", 
                                                           "C[Del(T):R(5,7)]G", "G[Del(T):R(5,7)]A", "G[Del(T):R(5,7)]C", 
                                                           "G[Del(T):R(5,7)]G", "A[Del(T):R(8,9)]A", "A[Del(T):R(8,9)]C", 
                                                           "A[Del(T):R(8,9)]G", "C[Del(T):R(8,9)]A", "C[Del(T):R(8,9)]C", 
                                                           "C[Del(T):R(8,9)]G", "G[Del(T):R(8,9)]A", "G[Del(T):R(8,9)]C", 
                                                           "G[Del(T):R(8,9)]G", "Del(2,4):R1", "Del(5,):R1", "Del(2,8):U(1,2):R(2,4)", 
                                                           "Del(2,):U(1,2):R(5,9)", "Del(3,):U(3,):R2", "Del(3,):U(3,):R(3,9)", 
                                                           "Del(2,5):M1", "Del(3,5):M2", "Del(4,5):M(3,4)", "Del(6,):M1", 
                                                           "Del(6,):M2", "Del(6,):M3", "Del(6,):M(4,)", "Complex"), 
                                             Indel = c("Ins(C)", "Ins(C)", "Ins(C)", "Ins(C)", "Ins(C)", 
                                                       "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", 
                                                       "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", 
                                                       "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", 
                                                       "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", 
                                                       "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", "Ins(T)", 
                                                       "Ins(T)", "Ins(T)", "Ins(2,)", "Ins(2,)", "Ins(2,)", 
                                                       "Ins(2,)", "Ins(2,)", "Ins(2,)", "Del(C)", "Del(C)", 
                                                       "Del(C)", "Del(C)", "Del(C)", "Del(C)", "Del(C)", 
                                                       "Del(C)", "Del(C)", "Del(C)", "Del(T)", "Del(T)", 
                                                       "Del(T)", "Del(T)", "Del(T)", "Del(T)", "Del(T)", 
                                                       "Del(T)", "Del(T)", "Del(T)", "Del(T)", "Del(T)", 
                                                       "Del(T)", "Del(T)", "Del(T)", "Del(T)", "Del(T)", 
                                                       "Del(T)", "Del(T)", "Del(T)", "Del(T)", "Del(T)", 
                                                       "Del(T)", "Del(T)", "Del(T)", "Del(T)", "Del(T)", 
                                                       "Del(2,):R(0,9)", "Del(2,):R(0,9)", "Del(2,):R(0,9)", 
                                                       "Del(2,):R(0,9)", "Del(2,):R(0,9)", "Del(2,):R(0,9)", 
                                                       "Del(2,):M(1,)", "Del(2,):M(1,)", "Del(2,):M(1,)", 
                                                       "Del(2,):M(1,)", "Del(2,):M(1,)", "Del(2,):M(1,)", 
                                                       "Del(2,):M(1,)", "Complex"), Indel3 = c("Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Insertion", "Insertion", "Insertion", 
                                                                                               "Insertion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Deletion", "Deletion", "Deletion", 
                                                                                               "Deletion", "Deletion", "Complex"), Figlabel = c("A[C0]A", 
                                                                                                                                                "A[C0]T", "C(0,3)", "C(4,6)", "C(7,9)", "A[T(0,4)]A", 
                                                                                                                                                "A[T(0,4)]C", "A[T(0,4)]G", "C[T(0,4)]A", "C[T(0,4)]C", 
                                                                                                                                                "C[T(0,4)]G", "G[T(0,4)]A", "G[T(0,4)]C", "G[T(0,4)]G", 
                                                                                                                                                "A[T(5,7)]A", "A[T(5,7)]C", "A[T(5,7)[G", "C[T(5,7)[A", 
                                                                                                                                                "C[T(5,7)[C", "C[T(5,7)[G", "G[T(5,7)[A", "G[T(5,7)[C", 
                                                                                                                                                "G[T(5,7)]G", "A[T(8,9)]A", "A[T(8,9)]C", "A[T(8,9)]G", 
                                                                                                                                                "C[T(8,9)]A", "C[T(8,9)]C", "C[T(8,9)]G", "G[T(8,9)]A", 
                                                                                                                                                "G[T(8,9)]C", "G[T(8,9)]G", "L(2,4):R0", "L(5, ):R0", 
                                                                                                                                                "L(2,4):R1", "L(5, ):R1", "L(2, ):R(2,4)", "L(2, ):R(5,9)", 
                                                                                                                                                "[C1]A", "[C1]T", "[C2]A", "[C2]T", "[C3]A", "[C3]T", 
                                                                                                                                                "[C(4,5)]A", "[C(4,5)]T", "[C(1,5)]G", "C(6,9)", 
                                                                                                                                                "A[T(1,4)]A", "A[T(1,4)]C", "A[T(1,4)]G", "C[T(1,4)]A", 
                                                                                                                                                "C[T(1,4)]C", "C[T(1,4)]G", "G[T(1,4)]A", "G[T(1,4)]C", 
                                                                                                                                                "G[T(1,4)]G", "A[T(5,7)]A", "A[T(5,7)]C", "A[T(5,7)]G", 
                                                                                                                                                "C[T(5,7)]A", "C[T(5,7)]C", "C[T(5,7)]G", "G[T(5,7)]A", 
                                                                                                                                                "G[T(5,7)]C", "G[T(5,7)]G", "A[T(8,9)]A", "A[T(8,9)]C", 
                                                                                                                                                "A[T(8,9)]G", "C[T(8,9)]A", "C[T(8,9)]C", "C[T(8,9)]G", 
                                                                                                                                                "G[T(8,9)]A", "G[T(8,9)]C", "G[T(8,9)]G", "L(2,4):R1", 
                                                                                                                                                "L(5, ):R1", "L(2,8):U(1,2):R(2,4)", "L(2, ):U(1,2):R(5,9)", 
                                                                                                                                                "L(3, ):U(3,):R2", "L(3, ):U(3,):R(3,9)", "L(2,5):M1", 
                                                                                                                                                "L(3,5):M2", "L(4,5):M(3,4)", "L(6, ):M1", "L(6, ):M2", 
                                                                                                                                                "L(6, ):M3", "L(6, ):M(4, )", "Complex")), class = "data.frame", 
                                        row.names = c(NA, -89L))
  muts_basis_melt <- reshape2::melt(muts_basis, "IndelType")
  muts_basis_melt <- merge(indel_type_4_figurelabel, muts_basis_melt, 
                           by = "IndelType", all.x = T)
  muts_basis_melt[is.na(muts_basis_melt)] <- 0
  names(muts_basis_melt) <- c("IndelType", "Indel", "Indel3", 
                              "Figlabel", "Sample", "freq")
  muts_basis_melt$Sample <- as.character(muts_basis_melt$Sample)
  # conversion to %
  muts_basis_melt <- muts_basis_melt %>%
    dplyr::group_by(Sample) %>%
    dplyr::mutate(freq = freq / sum(freq)) %>%
    dplyr::ungroup()
  
  indel_mypalette_fill <- c("#000000", "#762A83", "#EE3377", 
                            "#004488", "#997700", "#EE99AA", "#6699CC", "#EECC66")
  indel_positions <- indel_type_4_figurelabel$IndelType
  indel_positions_labels <- indel_type_4_figurelabel$Figlabel
  entry <- table(indel_type_4_figurelabel$Indel)
  order_entry <- c("Ins(C)", "Ins(T)", "Ins(2,)", "Del(C)", 
                   "Del(T)", "Del(2,):R(0,9)", "Del(2,):M(1,)", "Complex")
  entry <- entry[order_entry]
  blocks <- data.frame(Type = unique(indel_type_4_figurelabel$Indel), 
                       fill = indel_mypalette_fill, xmin = c(0, cumsum(entry)[-length(entry)]) + 
                         0.5, xmax = cumsum(entry) + 0.5)
  blocks$ymin <- max(muts_basis_melt$freq) * 1.08
  blocks$ymax <- max(muts_basis_melt$freq) * 1.2
  blocks$labels <- c("1bp C", "1bp T", ">=2bp", "1bp C", "1bp T", 
                     ">=2bp", "Mh", "X")
  blocks$cl <- c("black", "black", "black", "white", "white", 
                 "white", "white", "white")
  indel_mypalette_fill3 <- c("#000000", "#888888", "#DDDDDD")
  entry3 <- table(indel_type_4_figurelabel$Indel3)
  order_entry3 <- c("Insertion", "Deletion", "Complex")
  entry3 <- entry3[order_entry3]
  blocks3 <- data.frame(Type = unique(indel_type_4_figurelabel$Indel3), 
                        fill = indel_mypalette_fill3, xmin = c(0, cumsum(entry3)[-length(entry3)]) + 
                          0.5, xmax = cumsum(entry3) + 0.5)
  blocks3$ymin <- max(muts_basis_melt$freq) * 1.2
  blocks3$ymax <- max(muts_basis_melt$freq) * 1.32
  blocks3$labels <- c("Insertion", "Deletion", "X")
  blocks3$cl <- c("black", "white", "white")
  indel_mypalette_fill_all <- c("#000000", "#762A83", "#EE3377", 
                                "#004488", "#997700", "#888888", "#EE99AA", "#6699CC", 
                                "#EECC66", "#DDDDDD")
  p <- ggplot2::ggplot(data = muts_basis_melt, ggplot2::aes(x = IndelType, 
                                                            y = freq, fill = Indel)) + ggplot2::geom_bar(stat = "identity", 
                                                                                                         position = "dodge", width = 0.7) + ggplot2::xlab("Indel Types") + 
    ggplot2::ylab("Percentage")
  p <- p + ggplot2::scale_x_discrete(limits = indel_positions) + 
    ggplot2::scale_y_continuous(labels = scales::percent) + 
    ggplot2::ggtitle(plot_title)
  p <- p + ggplot2::scale_fill_manual(values = indel_mypalette_fill_all) + 
    ggplot2::coord_cartesian(ylim = c(0, unique(blocks3$ymax)), 
                             expand = FALSE)
  p <- p + ggplot2::theme_classic() + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, 
                                                                                         vjust = 0.5, size = 5, colour = "black", hjust = 1), 
                                                     axis.text.y = ggplot2::element_text(size = 10, colour = "black"), 
                                                     legend.position = "none", axis.title.x = ggplot2::element_text(size = 15), 
                                                     axis.title.y = ggplot2::element_text(size = 15))
  p <- p + ggplot2::geom_rect(data = blocks3, ggplot2::aes(xmin = xmin, 
                                                           ymin = ymin, xmax = xmax, ymax = ymax, fill = Type, colour = "white"), 
                              inherit.aes = F) + ggplot2::geom_text(data = blocks3, 
                                                                    ggplot2::aes(x = (xmax + xmin)/2, y = (ymax + ymin)/2, 
                                                                                 label = labels, colour = cl), size = text_size, fontface = "bold", 
                                                                    inherit.aes = F) + ggplot2::scale_colour_manual(values = c("black", 
                                                                                                                               "white"))
  p <- p + ggplot2::geom_rect(data = blocks, ggplot2::aes(xmin = xmin, 
                                                          ymin = ymin, xmax = xmax, ymax = ymax, fill = Type, colour = "white"), 
                              inherit.aes = F) + ggplot2::geom_text(data = blocks, 
                                                                    ggplot2::aes(x = (xmax + xmin)/2, y = (ymax + ymin)/2, 
                                                                                 label = labels, colour = cl), size = text_size, fontface = "bold", 
                                                                    inherit.aes = F)
  return(p)
}

# apply my modified function to plot all samples in a grid

# Make a list to store all plots
p_all <- list()

# Loop through each catalogue and generate a plot for each
for (i in seq_along(id_catalogues)) {
  muts_basis <- id_catalogues[[i]]
  sample_name <- names(id_catalogues)[i]
  # Assuming each muts_basis is a data frame with one column
  p <- my_gingle_percentage(
    data.frame(Sample = muts_basis[, 1], IndelType = rownames(muts_basis)),
    3,
    sample_name
  )
  p_all[[i]] <- p
}

pdf(file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/indelsig.tools.lib/all_samples_indel_catalogue_2.pdf", width = 40, height = 15)
do.call("grid.arrange", c(p_all, ncol = 6, nrow = 4))
dev.off()


### cosine similarity ### 

# splitting mutational catalogues into sets per genotype
MLH1 <- c(id_catalogues$`A2-1`, id_catalogues$`A2-2`)
MSH6 <- c(id_catalogues$`C1-1`, id_catalogues$`C12-1`, id_catalogues$`C12-2`, id_catalogues$`F7-1`)
MSH3 <- c(id_catalogues$`C1-2`, id_catalogues$`F10-1`, id_catalogues$`F10-2`, id_catalogues$`F7-2`)
MBD4 <- c(id_catalogues$`H2-1`, id_catalogues$`H2-2`)
WT <- c(id_catalogues$HC1, id_catalogues$HC2)
MLH1MSH6 <- c(id_catalogues$C10_1, id_catalogues$C7_1, id_catalogues$D6B)
MLH1MSH3 <- c(id_catalogues$D4_1, id_catalogues$D6_1)
MLH1MBD4 <- c(id_catalogues$E5_1, id_catalogues$E5_2, id_catalogues$E8_1, id_catalogues$E8_2)

# for plotting all the MSH6 and MSH3 samples together
MSH <- c(MSH6, MSH3, MLH1MSH6, MLH1MSH3)

# calculating correlation matrix for MSH6 using cos_similarity
# creating an empty matrix
n <- length(MSH)
MSH_matrix <- matrix(NA, nrow = n, ncol = n)
rownames(MSH_matrix) <- names(MSH)
colnames(MSH_matrix) <- names(MSH)
# filling the matrix with cos_similarity
for (i in 1:n) {
  for (j in 1:n) {
    MSH_matrix[i, j] <- cos_similarity(MSH[[i]], MSH[[j]])
  }
}

# plotting using pheatmap
# pheatmap(MSH3_matrix, 
#          display_numbers = TRUE,  # show the similarity values
#          cluster_rows = FALSE,    # no clustering if you want fixed order
#          cluster_cols = FALSE,    
#          main = "Cosine Similarity Heatmap")

# plotting with ggplot2
MSH_df <- as.data.frame(MSH_matrix)
MSH_df <- cbind(sample = names(MSH), MSH_df) # adding a sample column as id.vars for melt
MSH_df_melt <- pivot_longer(MSH_df, cols = 2:14, names_to = "sample_col", values_to = "cos_sim")

MSH_cos_sim <- ggplot(MSH_df_melt, aes(x = sample, y = sample_col, fill = cos_sim)) +
  geom_tile() +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  theme_minimal() +
  labs(title = "Cosine similarity", x = "", y = "") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(hjust = 0.5))
print(MSH_cos_sim)
