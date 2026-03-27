### running signature.tools.lib on my mutations catalogues ###

library(signature.tools.lib)
library(data.table)
library(tidyverse)
library(cosmicsig)

# read in the data 
subs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_denovo_merged.txt", sep = "\t", header = T)

# splitting the file into files per sample
split_list <- split(subs, subs$Sample)
sample_names <- names(split_list) # set sample names

# save as separate tsv files
file_names <- sapply(seq_along(split_list), function(i) {
  print(names(split_list[i]))
  # set the file names
  file_name <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_files_by_sample/", sample_names[i], ".txt")
  write.table(split_list[i], file_name, sep = "\t", col.names=colnames)
  
  return(file_name)
})

# tsv files - stripped down and renamed columns
subs_stripped <- subs[ , c(1:2, 4:5, 12)]
colnames <- c("chr", "position", "REF", "ALT", "sample")
colnames(subs_stripped) <- colnames
split_list_stripped <- split(subs_stripped, subs_stripped$sample)

file_names <- sapply(seq_along(split_list_stripped), function(i) {
  # set the file names
  file_name <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_files_by_sample_sigtools/", sample_names[i], ".txt")
  write.table(split_list_stripped[i], file_name, sep = "\t", col.names = colnames)
  
  return(file_name)
})

### code from signature.tools.lib GitHub, example 2 and 3 ###

#set the file names.
SNV_tab_files <- file_names
#name the vectors entries with the sample names
names(SNV_tab_files) <- sample_names

#load SNV data and convert to SNV mutational catalogues
SNVcat_list <- list()
for (i in 1:length(SNV_tab_files)){
  tmpSNVtab <- read.table(SNV_tab_files[i],sep = "\t",header = TRUE,
                          check.names = FALSE,stringsAsFactors = FALSE)
  #convert to SNV catalogue, see ?tabToSNVcatalogue or ?vcfToSNVcatalogue for details
  res <- tabToSNVcatalogue(subs = tmpSNVtab,genome.v = "hg38")
  colnames(res$catalogue) <- sample_names[i]
  SNVcat_list[[i]] <- res$catalogue
}
#bind the catalogues in one table
SNV_catalogues <- do.call(cbind,SNVcat_list)

#the catalogues can be plotted as follows
plotSubsSignatures(signature_data_matrix = SNV_catalogues,
                   plot_sum = TRUE,output_file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/SNV_catalogues.pdf")

#perform signature fit using a multi-step approach where organ-specific common and rare signatures are used
subs_fit_res <- FitMS(catalogues = SNV_catalogues,
                      exposureFilterType = "giniScaledThreshold",
                      useBootstrap = TRUE,
                      organ = "Colorectal")
plotFitMS(subs_fit_res,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/")

# using Fit instead of FitMS, colorectal signatures
#fit the organ-specific breast cancer signatures using the bootstrap signature fit approach
sigsToUse <- getOrganSignatures("Colorectal",typemut = "subs")
subs_fit_res_FIT <- Fit(catalogues = SNV_catalogues,
                    signatures = sigsToUse,
                    useBootstrap = TRUE,
                    nboot = 100,
                    nparallel = 4)
plotFit(subs_fit_res_FIT,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/Fit")

# Fit all COSMIC30 signatures
subs_fit_res_FITall <- Fit(catalogues = SNV_catalogues,
                        signatures = COSMIC30_subs_signatures,
                        useBootstrap = TRUE,
                        nboot = 100,
                        nparallel = 4)
plotFit(subs_fit_res_FITall,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/Fit_allCOSMIC")

# Fit most recent COSMIC signatures (3.3, June 2022)
latest_sbs_signatures <- signature$GRCh38$SBS96

subs_fit_res_FITall <- Fit(catalogues = SNV_catalogues,
                           signatures = latest_sbs_signatures,
                           useBootstrap = TRUE,
                           nboot = 100,
                           nparallel = 4)
plotFit(subs_fit_res_FITall,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/Fit_COSMICv3.3")

# Fit COSMIC v3.3 with giniScaledThreshold
subs_fit_res_FITall <- Fit(catalogues = SNV_catalogues,
                           signatures = latest_sbs_signatures,
                           exposureFilterType = "giniScaledThreshold",
                           useBootstrap = TRUE,
                           nboot = 100,
                           nparallel = 4)
plotFit(subs_fit_res_FITall,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/Fit_COSMICv3.3_gini")

# Fit manually subsetted COSMIC v3.3
sigsToUse <- c(1, 3, 5, 6, 13:16, 18, 20, 21, 25, 27, 28, 33, 37, 39, 47, 51)

subs_fit_res_FITall <- Fit(catalogues = SNV_catalogues,
                           signatures = latest_sbs_signatures[, sigsToUse],
                           useBootstrap = TRUE,
                           nboot = 100,
                           nparallel = 4)
plotFit(subs_fit_res_FITall,outdir = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/signature.tools.lib/Fit_COSMICv3.3_subset")


#The signature exposures can be found here and correspond to the median of the bootstrapped
#runs followed by false positive filters. See ?Fit for details
snv_exp <- subs_fit_res$exposures

#Convert the organ-specific signature exposures into reference signature exposures
snv_exp <- convertExposuresFromOrganToRefSigs(expMatrix = t(snv_exp[,1:(ncol(snv_exp)-1)]),typemut = "subs")

### code from signature.tools.lib GitHub, example 4 ###
# #set the file names.
# SNV_tab_files <- file_names
# #name the vectors entries with the sample names
# names(SNV_tab_files) <- sample_names
# 
# # call the signatureFit_pipeline
# pipeline_subs_res <- signatureFit_pipeline(SNV_tab_files = SNV_tab_files,
#                                            organ = "Colorectal",genome.v = "hg38",
#                                            fit_method = "FitMS",nparallel = 2)

  
