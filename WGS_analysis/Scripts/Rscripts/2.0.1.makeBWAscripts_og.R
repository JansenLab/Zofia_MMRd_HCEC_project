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
sampleList <- read.csv(file="~/Projects/chondrosarcomasMetProject/0.0.sampleLists/0.sampleList.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
samIDs <- unique(sampleList[["brady"]])

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# specify output locations
mainDir <- unique(sampleList[["analysisLoc"]])
fastqDir <- paste0(mainDir, "1.0.fastqFiles/")
outDir <- paste0(mainDir, "2.0.bamFiles/")

# specify report out
streamOut <- "/SAN/colcc/sarc_amf/0.0.code/reports/2.0.1.makeBWA/"

# specify script(s) out location (local - to upload)
scriptsOut <- "~/Projects/chondrosarcomasMetProject/0.0.code/sh/2.0.2.runBMW/"

# specify human genome reference
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

#############  code  #############

# make script output dir
system(command = scriptsOut)

# make read strings
readString <- c("_R1", "_R2")

for(currSet in 1:length(samIDs)){
 
  print(paste("####### making fastQC script for sample:", sampleList[currSet, "sampleID"], "#########"))
  
  # fastq files
  inputfileF <- paste0(fastqDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], readString[1], ".fastq.gz")
  inputfileR <- paste0(fastqDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], readString[2], ".fastq.gz")
  
  # specify log and error out files
  errorfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".out")
  
  outputBam <- paste(outDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], ".bam", sep="")
  outputBamSort <- paste(outDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], ".sorted.bam", sep="")
  
  readGroups <- paste("'@RG\\tID:", sampleList[currSet, "brady"],"\\tSM:", sampleList[currSet, "brady"],
                      "\\tPL:ILLUMINA\\tLB:", sampleList[currSet, "brady"],"\\tPU:lane1'", sep="")
  
  newDir <- paste0(outDir, sampleList[currSet, "brady"])
  
  outName <- paste0(scriptsOut, "2.0.1.runBWA_", sampleList[currSet, "brady"], ".sh") 
  runIDName <- paste0(sampleList[currSet, "brady"], "_bwa")
  
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

mkdir ", newDir,"    

echo reads in", sampleList[currSet, "brady"], "fastq:
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





