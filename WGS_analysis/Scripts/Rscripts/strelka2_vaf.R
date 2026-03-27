# script to calculate VAFs from Strelka2 VCF files

# reading in the vcf.gz.tbi files
# faster to read in the indexed file
library(VariantAnnotation)
vcf_snv_path <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_180724/A2-1/somatic.snvs.vcf.gz.tbi"
vcf_snv <- readVcf(vcf_snv_path)
vcf_id_path <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/strelka2_output/vcf_files_180724/A2-1/somatic.indels.vcf.gz.tbi"
vcf_id <- readVcf(vcf_id_path)

counts <- geno(header(vcf_snv))[5:8,]

param <- ScanVcfParam(geno = "AU")
vcf_snv1 <- readVcf(vcf_snv_path, param=param)
# doesn't do what I want

vcf_snv2 <- readGeno(vcf_snv_path, "FT", row.names=FALSE)
# doesn't work

vranges <- readVcfAsVRanges(vcf_snv_path, use.names = TRUE)