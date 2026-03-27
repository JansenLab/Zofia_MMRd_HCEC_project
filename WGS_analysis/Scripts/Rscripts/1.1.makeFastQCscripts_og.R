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
arguments <- commandArgs(trailingOnly = TRUE)

#check number of arguments
if(length(arguments)!=3){
  stop("\n#### arguments > 1.1.makeFastQCscripts.R <sample list file> <fastqDir> <scriptsOut> ####\n")
}

#get sample list infomration
#sampleList <- read.csv(file="~/Projects/glandSeqProject/glandList.LPWGS.csv", header=TRUE, stringsAsFactors=FALSE)
sampleList <- read.csv(file="~/projects/glandProject/glandList.exomes.csv", header=TRUE, stringsAsFactors=FALSE)
sampleList <- read.csv(file=arguments[1], header=TRUE, stringsAsFactors=FALSE)
sampleList <- sampleList[sampleList[["retain"]]==1, ]

runID <- "Will30092019"
sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]

#dir variable
outDir <- "/data/BCI-EvoCa2/marnix/data/1.0.fastqFiles/merged/"
outDir <- arguments[2]

scriptsOut <- "~/projects/gastricProject/A.runScripts/"
scriptsOut <- arguments[3]

system(command = paste("mkdir ", scriptsOut, "1.1.makeFastQC", sep=""))

readString <- matrix(c("_1", "_2", "reads1", "reads2"), nrow = 2, ncol = 2, byrow = TRUE)
for(currSet in 1:nrow(sampleList)){
 
  print(paste("####### making fastQC script for sample", sampleList[currSet, "sampleID"], "#########"))
  
  #for each read (forward reverse)
  
  inputfile1 <- paste(outDir, sampleList[currSet, "setID"], "/", sampleList[currSet, "sampleID"], "/", readString[2, 1], "/", sampleList[currSet, "sampleID"], readString[1, 1],".fastq.gz", sep="")
  
  inputfile2 <- paste(outDir, sampleList[currSet, "setID"], "/", sampleList[currSet, "sampleID"], "/", readString[2, 2], "/", sampleList[currSet, "sampleID"], readString[1, 2],".fastq.gz", sep="")
  
  outName <- paste(scriptsOut, "1.1.makeFastQC/", "runFastQC_", sampleList[currSet, "setID"], "_", sampleList[currSet, "sampleID"], ".sh", sep="") 
  
  totalStrings <- paste("#!/bin/sh
#$ -cwd
#$ -V
#$ -pe smp 1
#$ -l h_rt=5:0:0      # Request 5 hour runtime
#$ -l h_vmem=4G

./bin/FastQC/fastqc", inputfile1, inputfile2)
    
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
    
}





