# make Strelka2 scripts #

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# get sample list
samList <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv")
crispr1 <- samList[1:16, ]
crispr2 <- samList[17:29, ]

# paths
bamDir <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files"
outDir <- "/SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC"
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC"
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Strelka2/MC"
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

normalBam <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam"

# Loop over sample names (assuming 'samList' contains sample names as strings)
for (sample in crispr2$sample_id) {
  
  # sample-specific arguments
  outName <- paste0(scriptsOut, "/", sample, "_strelka2_MC.sh")
  runIDName <- paste0(sample, "_strelka2")
  errorLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".err")
  outLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".out")
  
  tumourBam <- paste0(bamDir, "/", sample, ".mkdub.bam")  # Update path construction
  runDir <- paste0(outDir, "/", sample, "/")
  strelka_exe_com <- paste0(runDir, "runWorkflow.py -m local -j 20")
  
  # Construct the script content as a single string
  scripts <- paste("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N", runIDName,"
#$ -e", errorLogFile,"
#$ -o", outLogFile,"

mkdir", runDir,"

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \\
  --normalBam", normalBam,"\\
  --tumorBam", tumourBam,"\\
  --referenceFasta", genomeRefFile,"\\
  --runDir", runDir,"
                   
# execution on a single local machine with 20 parallel jobs\n",
strelka_exe_com
)
  
  # Write the script content to a file
  write(scripts, file = outName)
}