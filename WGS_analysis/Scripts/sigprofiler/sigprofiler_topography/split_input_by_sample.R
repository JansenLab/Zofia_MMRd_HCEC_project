library(tidyverse)
library(data.table)
library(magrittr)

# read in the data
sbs <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/denovo_snv_sigprofiler.txt", sep = "\t", header = T)
id <- fread("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/denovo_id_sigprofiler.txt", sep = "\t", header = T)

#split by sample
sbs_split <- split(sbs, sbs$Sample)
id_split <- split(id, id$Sample)

# save as files
for (name in names(sbs_split)) {
  filename <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/input/sbs_per_sample/", name, "_sbs.txt")
  write_delim(sbs_split[[name]], filename, delim='\t')
  cat("Saved:", filename, "\n")
}

for (name in names(id_split)) {
  filename <- paste0("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/mutation_signatures/SP_topography/input/id_per_sample/", name, "_id.txt")
  write_delim(id_split[[name]], filename, delim='\t')
  cat("Saved:", filename, "\n")
}
