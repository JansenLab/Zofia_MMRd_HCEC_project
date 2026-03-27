library(data.table)
library(scales)
library(ggplot2)
library(GGally)

# install.packages("magrittr")
# library(magrittr)

# reading in the vcf file
vcfFile <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/filtered_vcf_persample/mutectCalls.chr22.C8A.nfm.filtered.vcf"
dataIn <- fread(file=vcfFile, sep="\t", header = TRUE, skip = "#CHROM")
dataIn <- as.data.frame(dataIn)
names(dataIn)[1] <- c("CHROM") # renaming the first column

# make new columns
dataIn_passed <- dataIn[dataIn$FILTER == "PASS", ]
samList <- names(dataIn[10:ncol(dataIn)])

# # counting characters in each row of each column
# sampleLenghts <- list()
# for (sample in samList) {
#   sampleLenghts[[paste0(sample, "length")]] <- nchar(dataIn[[sample]])
# }

### EXTRACTING DEPTH AND VAFS OF ALL VARIANTS ###

# FOR LOOP APPROACH - SLOW
vafVect <- c()
depthVect <- c()
 
for (sample in samList) {
 for (row in 1:nrow(dataIn)) {
   vafVect <- c(vafVect, as.numeric(unlist(strsplit(dataIn[[row, sample]], split = ":")))[3])
   depthVect <- c(depthVect, as.numeric(unlist(strsplit(dataIn[[row, sample]], split = ":")))[4])
 }
dataIn$vaf <- vafVect
colnames(dataIn)[ncol(dataIn)] <- paste0(sample, "_VAF")
dataIn$DP <- depthVect
colnames(dataIn)[ncol(dataIn)] <- paste0(sample, "_DP")
vafVect <- c()
depthVect <- c()
}
# some variants have NA in the VAF column

# LAPPLY APPROACH - FAST, FROM CHATGPT
dataIn_passed <- as.data.table(dataIn_passed) # Convert dataIn to a data.table
process_sample_dt <- function(sample) { # Define a function to process each sample column
  split_data <- tstrsplit(dataIn_passed[[sample]], ":", type.convert = TRUE) # Split the data in the sample column by ":"
  
  # Extract the 3rd and 4th elements and create new columns for VAF and DP
  dataIn_passed[, paste0(sample, "_VAF") := split_data[[3]]]
  dataIn_passed[, paste0(sample, "_DP") := split_data[[4]]]
}

lapply(samList, process_sample_dt) # Apply the function to each sample in samList using lapply


# filtering for VAFs discarded by germline and normal_artifact filters
dataIn_germline <- dataIn[dataIn[["FILTER"]] %in% c("germline", "normal_artifact"), ]

# filtering for high VAFs
dataIn_highVAF <- data.frame()

for (sample in seq(39, ncol(dataIn), 2)) {
  for (row in 1:nrow(dataIn)) {
   if dataIn[dataIn[[row,]]]
  }
}
  
# creating a summary data table
dataIn_summary <- dataIn_passed[, 12:ncol(dataIn_passed)]
dataIn_summary <- na.omit(dataIn_summary)
# removing the rows with NAs omits about 1800 variants - 5% of all variants

# calculating mean VAFIn
meanVAF <- c()

for (sample in seq(1, ncol(dataIn_summary), 2)) {
  meanVAF <- c(meanVAF, mean(dataIn_summary[[sample]]))
}

# calculating mean depth of variants
meanDP <- c()

for (sample in seq(2, ncol(dataIn_summary), 2)) {
  meanDP <- c(meanDP, mean(dataIn_summary[[sample]], na.omit = TRUE))
}
# some of the samples have depth > 30

dataIn_means <- as.data.frame(rbind(meanVAF, meanDP))
colnames(dataIn_means) <- samList

### VAF DISTRIBUTION PLOTS - FOR LOOP ###
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/vaf_chr22_v2_280524.pdf")
for (sample in seq(1, ncol(dataIn_summary), 2)) {
  p <- ggplot(dataIn_summary, aes(x = dataIn_summary[C8A_VAF])) +
    geom_histogram(bins=100) +
    labs(x = colnames(dataIn_summary[sample]), y = "count") +
    theme_light()
  
  print(p)
}
dev.off()

### VAF DISTRIBUTION PLOTS - LAPPLY ###
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/vaf_chr22_C8Anfm_filtered_070624.pdf")
for (sample in seq(1, ncol(dataIn_summary), 2)) {
  x_data <- as.numeric(dataIn_summary[[sample]]) # Ensure the data is numeric.
  x_data <- na.omit(x_data) # Remove NA values
  temp_df <- data.frame(x_data) # Create a temporary data frame
  
  # Create the plot
  p <- ggplot(temp_df, aes(x = x_data)) +
    geom_histogram(bins=100) +
    labs(x = colnames(dataIn_summary)[sample], y = "count") +
    theme_light()
  
  print(p)
}
dev.off()

# depth distribution
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/depth_chr22_v2_280524.pdf")
for (sample in seq(2, ncol(dataIn_summary), 2)) {
  p <- ggplot(dataIn_summary, aes(x = dataIn_summary[[sample]])) +
    geom_histogram(bins=30) +
    labs(x = colnames(dataIn_summary[sample]), y = "count") +
    theme_light()
  
  print(p)
}
dev.off()

# C8A has mean VAF = 0.5 and depth = 0 - something is clearly wrong with it

### READS TABLE - FUNCTIONAL ###
# Initialize an empty data frame for dataIn_reads
dataIn_reads <- data.frame()
# Function to process each row for a given sample
process_row <- function(row, sample) {
  readVect_temp <- unlist(strsplit(dataIn_passed[[row, sample]], split = ":"))
  last_element <- readVect_temp[length(readVect_temp)]
  readVect_temp <- as.numeric(unlist(strsplit(last_element, split = ",")))
  
  return(readVect_temp)
}

process_sample_full <- function(sample) {
  # Apply the row processing function to all rows
  result <- lapply(1:nrow(dataIn_passed), process_row, sample)
  
  # Combine the result into a matrix and convert to data frame
  result_matrix <- do.call(rbind, result)
  
  data.frame(
    ref_FS = result_matrix[, 1],
    ref_RS = result_matrix[, 2],
    nref_FS = result_matrix[, 3],
    nref_RS = result_matrix[, 4],
    sample = sample
  )
}

# Apply the process_sample_full function to all samples in samList
sample_results <- lapply(samList, process_sample_full)

# Combine all sample results into a single data frame
combined_results <- do.call(cbind, lapply(sample_results, function(df) {
  colnames(df) <- paste0(colnames(df), "_", df$sample[1])
  df <- df[, -5]  # Remove the 'sample' column used for identification
  df
}))

dataIn_reads <- combined_results # Add combined results to dataIn_reads
# nref usually zero both in filtered and unfiltered VCF files
# what does that mean for how confidently the variants are called?









# Initialize readVect as a named list
# Initialize dataIn_reads as a data frame with the correct number of rows
dataIn_reads <- data.frame(matrix(nrow = nrow(dataIn), ncol = 0))

for (sample in samList) {
  readVect <- list(ref_FS = c(), ref_RS = c(), nref_FS = c(), nref_RS = c())
  
  for (row in 1:nrow(dataIn)) {
    readVect_temp <- unlist(strsplit(dataIn[[row, sample]], split = ":"))[length(dataIn[[row, sample]])]
    readVect_temp <- as.numeric(unlist(strsplit(readVect_temp, split = ",")))
    readVect$ref_FS <- c(readVect$ref_FS, readVect_temp[1])
    readVect$ref_RS <- c(readVect$ref_RS, readVect_temp[2])
    readVect$nref_FS <- c(readVect$nref_FS, readVect_temp[3])
    readVect$nref_RS <- c(readVect$nref_RS, readVect_temp[4])
  }
  
  # Add columns to dataIn_reads
  dataIn_reads[[paste0(sample, "_ref_FS")]] <- readVect$ref_FS
  dataIn_reads[[paste0(sample, "_ref_RS")]] <- readVect$ref_RS
  dataIn_reads[[paste0(sample, "_nref_FS")]] <- readVect$nref_FS
  dataIn_reads[[paste0(sample, "_nref_RS")]] <- readVect$nref_RS
}


readVect <- c()
dataIn_reads <- data.frame()

for (sample in samList) {
  for (row in 1:nrow(dataIn_passed)) {
    readVect_temp <- unlist(strsplit(dataIn_passed[[row, sample]], split = ":"))[11]
    readVect_temp <- as.numeric(unlist(strsplit(readVect_temp, split = ",")))
    readVect <- c(readVect, readVect_temp)
  }
  dataIn_reads$ref_FS <- c(dataIn_reads$ref_FS, readVect[1])
  colnames(dataIn_reads)[ncol(dataIn_reads)] <- paste0(sample,"ref_FS")
  dataIn_reads$ref_RS <- c(dataIn_reads$ref_RS, readVect[2])
  colnames(dataIn_reads)[ncol(dataIn_reads)] <- paste0(sample,"ref_RS")
  dataIn_reads$nref_FS <- c(dataIn_reads$nref_FS, readVect[3])
  colnames(dataIn_reads)[ncol(dataIn_reads)] <- paste0(sample,"nref_FS")
  dataIn_reads$nref_RS <- c(dataIn_reads$nref_RS, readVect[4])
  colnames(dataIn_reads)[ncol(dataIn_reads)] <- paste0(sample,"nref_RS")

readVect_temp <- c()
readVect <- c()
}


