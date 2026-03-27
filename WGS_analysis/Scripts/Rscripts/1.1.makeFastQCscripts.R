# 1.1.makeFastQCscripts.R
# part of the variant calling best practices
# makes scripts to runs fastQC on a list of fastq files
#
###### notes #######
#
# example: 
# Rscript ~/Code/bestPractices/1.1.makeFastQCscripts.R ~/Projects/glandSeqProject/sampleList.csv /data/BCI-EvoCa2/wchc/glandSeqProject/1.fastqFiles/merged/ ~/Projects/glandSeqProject/runScripts/
#
# note requires fastq files to be organised into read1 and read2 dirs
#
#
#
###### begin ########

#get arguments from script
#arguments <- commandArgs(trailingOnly = TRUE)

#check number of arguments
#if(length(arguments)!=3){
 # stop("\n#### arguments > 1.1.makeFastQCscripts.R <sample list file> <fastqDir> <scriptsOut> ####\n")
#}

#get sample list infomration
#sampleList <- read.csv(file="~/Projects/glandSeqProject/glandList.LPWGS.csv", header=TRUE, stringsAsFactors=FALSE)
#sampleList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv", header=TRUE, stringsAsFactors=FALSE) 
#sampleList <- read.csv(file=arguments[1], header=TRUE, stringsAsFactors=FALSE)
#sampleList <- sampleList[sampleList[["retain"]]==1, ]
sampleList <- c("HCEC-MC", "MLH1-A6-PC")

#runID <- "Will30092019"
#sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]

#dir variable
outDir <- "/SAN/colcc/MMRd_HCEC_genomes/fastq_files"
#outDir <- arguments[2]

scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/" 
#scriptsOut <- arguments[3]

system(command = paste("mkdir ", scriptsOut, "1.1.makeFastQC", sep=""))
#creates the directory locally where scripts will be stored

readString <- c("_R1", "_R2")
for(currSet in 1:length(sampleList)){
 
  print(paste("####### making fastQC script for sample", sampleList[currSet], "#########"))
  
  #for each read (forward reverse)
  
  inputfile1 <- paste(outDir, "/", sampleList[currSet], readString[1],".fastq.gz", sep="")
  
  inputfile2 <- paste(outDir, "/", sampleList[currSet], readString[2],".fastq.gz", sep="")

  outName <- paste(scriptsOut, "1.1.makeFastQC/", "runFastQC_", sampleList[currSet], ".sh", sep="") 
  
  totalStrings <- paste("#!/bin/sh
#$ -cwd
#$ -V
#$ -l tmem=4G
#$ -l h_vmem=4G
#$ -l h_rt=5:0:0      # Request 5 hour runtime

export PATH=\"/share/apps/jdk1.8.0_131/bin/:\\$PATH\"

/share/apps/genomics/FastQC-0.11.9/fastqc --outdir /SAN/colcc/MMRd_HCEC_genomes/fastqc/reports", inputfile1, inputfile2)
    
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
    
}




