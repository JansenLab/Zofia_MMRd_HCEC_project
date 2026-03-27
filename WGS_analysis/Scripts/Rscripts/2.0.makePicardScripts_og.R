# 1.4.makePicardscripts.R
# part of the variant calling best practices
# makes Picard mkdub and index alignment scripts
#
###### notes #######
#
# example: 
# Rscript ~/Code/bestPractices/1.4.makePicardscripts.R ~/Projects/glandSeqProject/sampleList.csv /data/BCI-EvoCa2/wchc/glandSeqProject/2.processedBams/ ~/Projects/glandSeqProject/C.runScripts/
#
# note requires fastq files to be organised into read1 and read2 dirs
#
#
#
###### begin ########

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")


#get arguments from script
arguments <- commandArgs(trailingOnly = TRUE)

#check number of arguments
if(length(arguments)!=3){
  stop("\n#### arguments > 1.4.makePicardscripts.R <sample list file> <bamDir> <scriptsOut> ####\n")
}

#get sample list infomration
sampleList <- read.csv(file="~/Projects/chondrosarcomasMetProject/0.0.sampleLists/0.sampleList.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
samIDs <- unique(sampleList[["brady"]])


#subset
runID <- ""
# runID <- ""
# sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]


bamDir <- paste0(sampleList[1,"analysisLoc"], "2.0.bamFiles/", sep="")
# bamDir <- "/data/BCI-EvoCa-SG/1.3.bamFiles/genomes/"
# bamDir <- arguments[2]

# specify report out
streamOut <- "/SAN/colcc/sarc_amf/0.0.code/reports/2.0.1.makePicard/"

scriptsOut <- "~/Projects/chondrosarcomasMetProject/0.0.code/sh/2.0.1.runPicard/"
# scriptsOut <- arguments[3]

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

system(command = paste("mkdir ", scriptsOut, sep=""))

for(currSet in 1:nrow(sampleList)){
  
  print(paste("####### making Picard script for sample", sampleList[currSet, "sampleID"], "#########"))
  
  inBam <- paste(bamDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], ".sorted.bam", sep="")
  inBam2 <- paste(bamDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"],".fixed.bam", sep="")
  
  outBamDub <- paste(bamDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], ".mkdub.bam", sep="")
  outDubMetrics <- paste(bamDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"],".mkdub.metrics.txt", sep="")
  
  runIDName <- paste0(sampleList[currSet, "brady"], "_picard")
  
  errorfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".out")
  
  outName <- paste0(scriptsOut, "2.0.1.runPicard_", sampleList[currSet, "brady"], ".sh") 
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \\
INPUT=", inBam," \\
OUTPUT=", inBam2, " \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=/SAN/colcc/sarc_amf/2.0.bamFiles/", sampleList[currSet, "brady"],"

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \\
INPUT=", inBam2," \\
OUTPUT=", outBamDub," \\
METRICS_FILE=", outDubMetrics," \\
CREATE_INDEX=true \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=/SAN/colcc/sarc_amf/2.0.bamFiles/", sampleList[currSet, "brady"],"
                        
#build index file
samtools index ", outBamDub,"

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=", outBamDub," MODE=SUMMARY

rm ", inBam2, sep="")
      
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)

}






