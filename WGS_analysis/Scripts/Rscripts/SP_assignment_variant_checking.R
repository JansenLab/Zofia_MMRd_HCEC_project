library(tidyverse)
library(data.table)

# read in the data
sbs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/snv_all_merged.txt",  sep = "\t", header = T)
id <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/figures_WGS_30x/id_all_merged.txt", sep = "\t", header = T)

### POLD1 ###

# POLD1 gene coordinates (from GeneCards)
POlD1 <- "chr19:50,384,204-50,418,018"

# filter data for chr19 only
sbs_filt_POLD1 <- sbs[sbs$CHROM == "chr19", ]
id_filt_POLD1 <- id[id$CHROM == "chr19", ]
# filter for coordinates
sbs_filt_POLD1 <- sbs_filt_POLD1[sbs_filt_POLD1$POS > 50384204 & sbs_filt_POLD1$POS < 50418018]
id_filt_POLD1 <- id_filt_POLD1[id_filt_POLD1$POS > 50384204 & id_filt_POLD1$POS < 50418018]

### HR pathway ###
BRCA1 <- "chr17:43,044,295-43,170,327"
BRCA2 <- "chr13:32,315,077-32,400,268"
PALB2 <- "chr16:23,603,160-23,641,321"
RAD51 <- "chr15:40,694,733-40,732,340"

# BRCA1
# filter data for chr
sbs_filt_BRCA1 <- sbs[sbs$CHROM == "chr17", ]
id_filt_BRCA1 <- id[id$CHROM == "chr17", ]
# filter for coordinates
sbs_filt_BRCA1 <- sbs_filt_BRCA1[sbs_filt_BRCA1$POS > 43044295 & sbs_filt_BRCA1$POS < 43170327]
id_filt_BRCA1 <- id_filt_BRCA1[id_filt_BRCA1$POS > 43044295 & id_filt_BRCA1$POS < 43170327]

# BRCA2
# filter data for chr
sbs_filt_BRCA2 <- sbs[sbs$CHROM == "chr13", ]
id_filt_BRCA2 <- id[id$CHROM == "chr13", ]
# filter for coordinates
sbs_filt_BRCA2 <- sbs_filt_BRCA2[sbs_filt_BRCA2$POS > 32315077 & sbs_filt_BRCA2$POS < 32400268]
id_filt_BRCA2 <- id_filt_BRCA2[id_filt_BRCA2$POS > 32315077 & id_filt_BRCA2$POS < 32400268]

#PALB2
# filter data for chr
sbs_filt_PALB2 <- sbs[sbs$CHROM == "chr16", ]
id_filt_PALB2 <- id[id$CHROM == "chr16", ]
# filter for coordinates
sbs_filt_PALB2 <- sbs_filt_PALB2[sbs_filt_PALB2$POS > 23603160 & sbs_filt_PALB2$POS < 23641321]
id_filt_PALB2 <- id_filt_PALB2[id_filt_PALB2$POS > 23603160 & id_filt_PALB2$POS < 23641321]

#RAD51
# filter data for chr
sbs_filt_RAD51 <- sbs[sbs$CHROM == "chr15", ]
id_filt_RAD51 <- id[id$CHROM == "chr15", ]
# filter for coordinates
sbs_filt_RAD51 <- sbs_filt_RAD51[sbs_filt_RAD51$POS > 40694733 & sbs_filt_RAD51$POS < 40732340]
id_filt_RAD51 <- id_filt_RAD51[id_filt_RAD51$POS > 40694733 & id_filt_RAD51$POS < 40732340]
