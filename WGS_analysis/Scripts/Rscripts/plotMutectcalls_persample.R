library(data.table)
library(scales)
library(ggplot2)
library(GGally)

install.packages("magrittr")
library(magrittr)

# reading in the vcf file
sampleSheet <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv", header=TRUE, stringsAsFactors=FALSE)
samList <- sampleSheet[["sample_id"]]
vcfLoc <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/filtered_vcf_persample/"

# loading the VCF files for all samples
for (sample in samList) {
  vcfFile <- paste0(vcfLoc, "mutectCalls.chr22.", sample, ".filtered.vcf")
  dataIn <- fread(file=vcfFile, sep="\t", header = TRUE, skip = "#CHROM")
  dataIn <- as.data.frame(dataIn)
  names(dataIn)[1] <- c("CHROM") # renaming the first column
  assign(paste0(sample, "_vcf"), dataIn)
}

# removing samples without any variants
rm(C8A_vcf)
rm(HC1_vcf)
samList <- samList[-1]
samList <- samList[-26]

# making a list of all the vcf files
all_objects <- ls() # List all objects in the environment
vcf_names <- grep("_vcf$", all_objects, value = TRUE) # Filter names that end with "_vcf"
vcf_list <- mget(vcf_names) # Retrieve the objects with the filtered names and store them in a list
print(vcf_list) # Print the list to check

# make new columns
for (i in 1:length(vcf_names)) {
  file <- vcf_names[i]
  data <- vcf_list[[i]]
  data <- data[data$FILTER == "PASS", ]
  vcf_list[[i]] <- data
}

# # counting characters in each row of each column
# sampleLenghts <- list()
# for (sample in samList) {
#   sampleLenghts[[paste0(sample, "length")]] <- nchar(dataIn[[sample]])
# }

# extracting depths and VAFs of each variant

# doesn't work for  C8A - had to skip that one - deleting to stop it from interfering with the loop
# samList <- samList[-21]
# vcf_names <- vcf_names[-15]
# vcf_list <- vcf_list[-15]

vafVect <- c()
depthVect <- c()

for (i in 1:length(vcf_names)) {
  file <- vcf_names[i]
  data <- vcf_list[[i]]
  for (sample in 10:ncol(data)) {
    for (row in 1:nrow(data)) {
      strSplit <- as.numeric(unlist(strsplit(data[row, sample], split = ":")))
      vafVect <- c(vafVect, strSplit[3])
      depthVect <- c(depthVect, strSplit[4])
    }
    data <- cbind(data, vafVect)
    colnames(data)[ncol(data)] <- paste0(colnames(data)[sample], "_VAF")
    data <- cbind(data, depthVect)
    colnames(data)[ncol(data)] <- paste0(colnames(data)[sample], "_DP")
    vafVect <- c()
    depthVect <- c()
  }
  vcf_list[[i]] <- data  # Ensure the updated data is assigned back to vcf_list
}

# creating a summary data table
# dataIn_summary <- dataIn_passed[39:ncol(dataIn_passed)]
# dataIn_summary <- na.omit(dataIn_summary)
# removing the rows with NAs omits about 1800 variants - 5% of all variants

# calculating mean VAF of KOs
meanVAF_KOs <- c()  

for (i in 1:(length(vcf_names)-1)) {
  data <- vcf_list[[i]]
  meanVAF <- mean(data[, 12], na.rm = TRUE)
  print(meanVAF)
  meanVAF_KOs <- c(meanVAF_KOs, meanVAF)
}
print(meanVAF_KOs)

# mean VAF of HC2 - it has HC1 and HC2 in a reverse order
data <- vcf_list[[22]][, 14]
meanVAF_KOs <- c(meanVAF_KOs, mean(data, na.rm = TRUE))
print(meanVAF_KOs)

# calculating mean VAF of normals
meanVAF_normals <- c()  

for (i in 1:(length(vcf_names)-1)) {
  data <- vcf_list[[i]]
  meanVAF <- mean(data[, 14], na.rm = TRUE)
  print(meanVAF)
  meanVAF_normals <- c(meanVAF_normals, meanVAF)
}
print(meanVAF_normals)

# mean VAF of HC1 for HC2 
data <- vcf_list[[22]][, 12]
meanVAF_normals <- c(meanVAF_normals, mean(data, na.rm = TRUE))
print(meanVAF_normals)

# calculating mean depth of KO variants
meanDP_KOs <- c()

for (i in 1:(length(vcf_names)-1)) {
  data <- vcf_list[[i]]
  meanDP <- mean(data[, 13], na.rm = TRUE)
  print(meanDP)
  meanDP_KOs <- c(meanDP_KOs, meanDP)
}
print(meanDP_KOs)

# mean depth for HC2
data <- vcf_list[[22]][, 15]
meanDP_KOs <- c(meanDP_KOs, mean(data, na.rm = TRUE))
print(meanDP_KOs)

# calculating mean depth of normal variants
meanDP_normals <- c()

for (i in 1:(length(vcf_names)-1)) {
  data <- vcf_list[[i]]
  meanDP <- mean(data[, 15], na.rm = TRUE)
  print(meanDP)
  meanDP_normals <- c(meanDP_normals, meanDP)
}
print(meanDP_normals)

# mean depth for HC2
data <- vcf_list[[22]][, 13]
meanDP_normals <- c(meanDP_normals, mean(data, na.rm = TRUE))
print(meanDP_normals)

data_means <- as.data.frame(rbind(meanVAF_KOs, meanVAF_normals, meanDP_KOs, meanDP_normals))
colnames(data_means) <- vcf_names

# VAF distribution plots - KOs
# repeat when all samples run
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/persample_filtered_vaf_chr22_210524.pdf")
for (i in 1:(length(vcf_list))) {
  data <- vcf_list[[i]]
  p <- ggplot(data, aes(x = data[, 12])) +
    geom_histogram(bins=100) +
    #coord_cartesian(ylim = c(0,20), clip = "off") +
    labs(x = colnames(data[12]), y = "count") +
    theme_light()
  
  print(p)
}

data <- as.data.frame(na.omit(vcf_list[[27]][, 14]))

p <- ggplot(data, aes(x = data[, 1])) +
  geom_histogram(bins=100) +
  labs(x = "HC2_VAF", y = "count") +
  theme_light()

print(p)

dev.off()

# VAF distribution plots - normals
# repeat when all samples run
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/persample_unfiltered_normals_vaf_chr22_210524.pdf")
for (i in 1:(length(vcf_list)-1)) {
  data <- vcf_list[[i]]
  p <- ggplot(data, aes(x = data[, 14])) +
    geom_histogram(bins=100) +
    labs(x = colnames(data[14]), y = "count") +
    theme_light()
  
  print(p)
}
dev.off()

# depth distribution
pdf("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutect2_output/filtered_depth_chr22_200524.pdf")
for (i in 1:(length(vcf_list)-1)) {
  data <- vcf_list[[i]]
  p <- ggplot(data, aes(x = data[, 15])) +
    geom_histogram(bins=100) +
    labs(x = colnames(data[15]), y = "count") +
    theme_light()
  
  print(p)
}
dev.off()

# C8A has mean VAF = 0.5 and depth = 0 - something is clearly wrong with it

# extracting number of reference and non-reference reads
# not working - edit
readVect <- c()
dataIn_reads <- list()

for (sample in samList) {
  for (row in 1:nrow(dataIn)) {
    readVect_temp <- unlist(strsplit(dataIn[[row, sample]], split = ":"))[11]
    readVect_temp <- as.numeric(unlist(strsplit(readVect_temp, split = ",")))
    readVect <- c(readVect, readVect_temp)
  }
dataIn_reads$ref_FS <- readVect[1]
colnames(dataIn)[ncol(dataIn)] <- paste0(sample,"ref_FS")
dataIn_reads$ref_RS <- readVect[2]
colnames(dataIn)[ncol(dataIn)] <- paste0(sample,"ref_RS")
dataIn_reads$nref_FS <- readVect[3]
colnames(dataIn)[ncol(dataIn)] <- paste0(sample,"nref_FS")
dataIn_reads$nref_RS <- readVect[4]
colnames(dataIn)[ncol(dataIn)] <- paste0(sample,"nref_RS")

readVect_temp <- c()
readVect <- c()
}


