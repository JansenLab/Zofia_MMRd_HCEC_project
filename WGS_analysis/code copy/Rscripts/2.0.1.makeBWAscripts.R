# Script: 2.0.1.makeBWAscripts.R
# Project: Chondrosarcoma Metastasis Project
# Location: UCL Myriad
# Author: William Cross (UCL Cancer Institute)
# Version Date: 
# 
############  notes  #############
#
# raw sequencing data
#         |
#         V
# 1.0.1.makeFastQCscripts.R
#         |
#         V
# manual inspection
#         |
#         V
# 2.0.1.makeBWAscripts.R
#         |
#         V
#       . . .
# 
#############  libs  #############
 
# none

#############  loads  #############

# get sample list 
# sampleList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv", header=TRUE, stringsAsFactors=FALSE)
sampleList <- c("HCEC-MC", "MLH1-A6-PC")

# make the list of indices to iterate over every second row in the sample list
#indices <- seq(1, nrow(sampleList), by = 2)

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# specify output locations
# mainDir <- unique(sampleList[["analysisLoc"]])
fastqDir <- "/SAN/colcc/MMRd_HCEC_genomes/fastq_files/"
outDir <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/"

# specify report out
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/"

# specify script(s) out location (local - to upload)
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/2.runBWM/"

# specify human genome reference
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

#############  code  #############

# make script output dir
system(command = scriptsOut)

# make read strings
readString <- c("_R1", "_R2")

for(currSet in 1:length(sampleList)){ #edit
 
  print(paste("####### making fastQC script for sample:", sampleList[currSet], "#########"))
  
  # fastq files
  inputfileF <- paste0(fastqDir, sampleList[currSet], readString[1], ".fastq.gz")
  inputfileR <- paste0(fastqDir, sampleList[currSet], readString[2], ".fastq.gz")
  
  # specify log and error out files
  errorfile <- paste0(streamOut, sampleList[currSet], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet], ".", dateTag, ".out")
  
  outputBam <- paste(outDir, sampleList[currSet], ".bam", sep="")
  outputBamSort <- paste(outDir, sampleList[currSet], ".sorted.bam", sep="")
  
  readGroups <- paste("'@RG\\tID:", sampleList[currSet],"\\tSM:", sampleList[currSet],
                      "\\tPL:ILLUMINA\\tLB:", sampleList[currSet],"\\tPU:lane1'", sep="")
  
  #newDir <- paste0(outDir, sampleList[currSet, "clone"], sampleList[currSet, "subclone"])
  
  outName <- paste0(scriptsOut, "2.0.1.runBWA_", sampleList[currSet], ".sh") 
  runIDName <- paste0(sampleList[currSet], "_bwa")
  
  # one script for each pair (forward & reverse)
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N", runIDName,"
#$ -e", errorfile,"
#$ -o", outLogfile,"

echo reads in", sampleList[currSet], "fastq:
zcat", inputfileF," | echo $((`wc -l`/4))

# align data 
bwa mem -M -t 12 -R", readGroups, genomeRefFile, inputfileF, inputfileR, "| \\
samtools view -q 1 -bS - > ", outputBam, "

# sort new bam file
samtools sort -o ", outputBamSort, outputBam,"

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=", outputBamSort," MODE=SUMMARY

")
    
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
}





