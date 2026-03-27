# a script to format the txt mutation files for sig profiler #

library(tidyverse)
library(data.table)
library(magrittr)

# read in the data
sbs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/mutation_signatures/denovo_snv_sigprofiler.txt", sep = "\t", header = T)
id <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/mutation_signatures/denovo_id_sigprofiler.txt", sep = "\t", header = T)

# format the sbs file
sbs$Project <- "WGS_30x"
sbs$ID <- "."
sbs$Genome <- "GRCh38"
sbs$mut_type <- "SNV"
sbs$Type <- "SOMATIC"

# save the new file
write.table(sbs, file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/mutation_signatures/denovo_snv_sigprofiler.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# format the id file
id$Project <- "WGS_30x"
id$ID <- "."
id$Genome <- "GRCh38"
id$mut_type <- "ID"
id$Type <- "SOMATIC"

# calculate the pos_end values (chatgpt code) - avoids looping
# First, initialize pos_end as pos_start
id$pos_end <- id$pos_start
# Compute length difference between alt and ref
length_diff <- nchar(id$alt) - nchar(id$ref)
# Identify insertions and deletions
is_indel <- id$ref != id$alt
# Apply length adjustment only to indels
# abs() ensures that both insertions and deletions are handled correctly
id$pos_end[is_indel] <- id$pos_start[is_indel] + abs(length_diff[is_indel])

# save the new file
write.table(id, file = "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/mutation_signatures/denovo_id_sigprofiler.txt", sep = "\t", row.names = FALSE, quote = FALSE)

