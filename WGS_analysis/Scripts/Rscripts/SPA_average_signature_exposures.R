# calculate average mutation signature exposures for the SPA results

library(tidyverse)

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

# find out ID signatures with no exposure in my dataset
cols_to_sum <- 1 : (ncol(ID_norm_ordered) - 2)
sum_values <- colSums(ID_norm_ordered[ , cols_to_sum])
sum_row_df <- as.data.frame(t(sum_values)) # convert to df
sum_row_df$sum <- "colSum" # adding new columns to make the format match SBS_norm_ordered
sum_row_df$Samples <- "all"
ID_norm_ordered <- rbind(ID_norm_ordered, sum_row_df) # attach the colSum values to the original df

zero_exp_sigs <- (ID_norm_ordered[24, ] == 0) # creating a logical vector to act as a filter
zero_cols_names <- names(ID_norm_ordered)[zero_exp_sigs]

# filter out signatures with zero exp
cols_to_keep <- !(names(ID_norm_ordered) %in% zero_cols_names)
ID_filtered <- ID_norm_ordered[1:23, cols_to_keep] # remove the colSums row, not needed anymore

# split by hypermutators and low-mutators
SBS_filtered_hypermut <- SBS_filtered[SBS_filtered$Samples %in% hypermutators, ]
SBS_filtered_lowmut <- SBS_filtered[SBS_filtered$Samples %in% low_mutators, ]

ID_filtered_hypermut <- ID_filtered[ID_filtered$Samples %in% hypermutators, ]
ID_filtered_lowmut <- ID_filtered[ID_filtered$Samples %in% low_mutators, ]

# calculate the average exposure of SBS1 and SBS5 in the whole dataset
average_sbs_all <- data.frame(matrix(NA, nrow = 1, ncol = 22))
colnames(average_sbs_all) <- colnames(SBS_filtered)
SBS_filtered <- rbind(SBS_filtered, average_sbs_all)
SBS1_mean <- mean(SBS_filtered[1:23, "SBS1"])
SBS5_mean <- mean(SBS_filtered[1:23, "SBS5"])
SBS_filtered[24, "SBS1"] <- SBS1_mean
SBS_filtered[24, "SBS5"] <- SBS5_mean

# for all ID signatures
average_id_all <- data.frame(matrix(NA, nrow = 1, ncol = 10))
colnames(average_id_all) <- colnames(ID_filtered)
ID_filtered <- rbind(ID_filtered, average_id_all)
ID_filtered[24, 1:8] <- sapply(1:8, function(x) {
  mean(ID_filtered[1:23, x][ID_filtered[1:23, x] != 0])
})

# for all SBS signatures in hypermutators
# first calculate with zeroes to remove any signatures with mean = 0
average_sbs_hypermut <- data.frame(matrix(NA, nrow = 1, ncol = 22))
colnames(average_sbs_hypermut) <- colnames(SBS_filtered_hypermut)
SBS_filtered_hypermut <- rbind(SBS_filtered_hypermut, average_sbs_hypermut)
SBS_filtered_hypermut[16, 1:20] <- sapply(1:20, function(x) {
  mean(SBS_filtered_hypermut[1:15, x])
})
# filter out signatures with mean = 0 
keep_cols <- SBS_filtered_hypermut[16, ] != 0
keep_cols[22] <- TRUE # to keep the sample column 
SBS_filtered_hypermut <- SBS_filtered_hypermut[, which(keep_cols)]
# recalculate the mean excluding zeroes
SBS_filtered_hypermut[16, 1:10] <- sapply(1:10, function(x) {
  mean(SBS_filtered_hypermut[1:15, x][SBS_filtered_hypermut[1:15, x] != 0])
})

# for all SBS signatures in low-mutators
# first calculate with zeroes to remove any signatures with mean = 0
average_sbs_lowmut <- data.frame(matrix(NA, nrow = 1, ncol = 22))
colnames(average_sbs_lowmut) <- colnames(SBS_filtered_lowmut)
SBS_filtered_lowmut <- rbind(SBS_filtered_lowmut, average_sbs_lowmut)
SBS_filtered_lowmut[9, 1:20] <- sapply(1:20, function(x) {
  mean(SBS_filtered_lowmut[1:8, x])
})
# filter out signatures with mean = 0 
keep_cols <- SBS_filtered_lowmut[9, ] != 0
keep_cols[22] <- TRUE # to keep the sample column 
SBS_filtered_lowmut <- SBS_filtered_lowmut[, which(keep_cols)]
# recalculate the mean excluding zeroes
SBS_filtered_lowmut[9, 1:13] <- sapply(1:13, function(x) {
  mean(SBS_filtered_lowmut[1:8, x][SBS_filtered_lowmut[1:8, x] != 0])
})

# for all ID signatures in hypermutators
ID_filtered_hypermut <- rbind(ID_filtered_hypermut, average_id_all)
ID_filtered_hypermut[16, 1:8] <- sapply(1:8, function(x) {
  mean(ID_filtered_hypermut[1:15, x])
})
# filter out signatures with mean = 0 
keep_cols <- ID_filtered_hypermut[16, ] != 0
keep_cols[10] <- TRUE # to keep the sample column 
ID_filtered_hypermut <- ID_filtered_hypermut[, which(keep_cols)]
# recalculate the mean excluding zeroes
ID_filtered_hypermut[16, 1:2] <- sapply(1:2, function(x) {
  mean(ID_filtered_hypermut[1:15, x][ID_filtered_hypermut[1:15, x] != 0])
})

# for all ID signatures in hypermutators
ID_filtered_lowmut <- rbind(ID_filtered_lowmut, average_id_all)
ID_filtered_lowmut[9, 1:8] <- sapply(1:8, function(x) {
  mean(ID_filtered_lowmut[1:8, x])
})
# filter out signatures with mean = 0 
keep_cols <- ID_filtered_lowmut[9, ] != 0
keep_cols[10] <- TRUE # to keep the sample column 
ID_filtered_lowmut <- ID_filtered_lowmut[, which(keep_cols)]
# recalculate the mean excluding zeroes
ID_filtered_lowmut[9, 1:8] <- sapply(1:8, function(x) {
  mean(ID_filtered_lowmut[1:8, x][ID_filtered_lowmut[1:8, x] != 0])
})

# save the activities files
write_csv(SBS_filtered, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS_activities.csv")
write_csv(SBS_filtered_hypermut, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS_activities_hypermut.csv")
write_csv(SBS_filtered_lowmut, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/SBS_activities_lowmut.csv")

write_csv(ID_filtered, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID_activities.csv")
write_csv(ID_filtered_hypermut, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID_activities_hypermut.csv")
write_csv(ID_filtered_lowmut, "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_assignment_output/ID_activities_lowmut.csv")

