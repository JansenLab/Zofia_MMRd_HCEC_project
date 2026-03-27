# make Manta scripts #

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# get sample list
samList <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv")
crispr1 <- samList[3:18, ]
crispr2 <- samList[19:31, ]

# paths
bamDir <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files"
outDir <- "/SAN/colcc/MMRd_HCEC_genomes/manta/output"
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/manta/reports"
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Manta"
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

normalBam <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam"

# Loop over sample names (assuming 'samList' contains sample names as strings)
for (sample in crispr1$sample_id) {
  
  # sample-specific arguments
  outName <- paste0(scriptsOut, "/", sample, "_manta.sh")
  runIDName <- paste0(sample, "_manta")
  errorLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".err")
  outLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".out")
  
  tumourBam <- paste0(bamDir, "/", sample, ".mkdub.bam")  # Update path construction
  runDir <- paste0(outDir, "/", sample, "/")
  manta_exe_com <- paste0(runDir, "runWorkflow.py -m local -j 20")
  
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

/share/apps/genomics/manta-1.6.0/bin/configManta.py \\
  --normalBam", normalBam,"\\
  --tumorBam", tumourBam,"\\
  --referenceFasta", genomeRefFile,"\\
  --runDir", runDir,"
                   
# execution on a single local machine with 20 parallel jobs\n",
                   manta_exe_com
  )
  
  # Write the script content to a file
  write(scripts, file = outName)
}