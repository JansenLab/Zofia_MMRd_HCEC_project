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
# f(length(arguments)!=3){
#  stop("\n#### arguments > 1.4.makePicardscripts.R <sample list file> <bamDir> <scriptsOut> ####\n")
#} #comment out

#get sample list infomration
sampleList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv", header=TRUE, stringsAsFactors=FALSE)

# make the list of indices to iterate over every second row in the sample list
indices <- seq(1, nrow(sampleList), by = 2)


#subset
# runID <- "" # what is this for?
# runID <- ""
# sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]


# bamDir <- paste0("bam_files/", sampleList[1,"bam_file_loc"], sep="") # seems like this requires me to add a column to the master file listing directories with bam files 
# bamDir <- "/data/BCI-EvoCa-SG/1.3.bamFiles/genomes/"
# bamDir <- arguments[2]
 
# specify report out
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/picard/reports/"

scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/runPicard/"
# scriptsOut <- arguments[3]

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

system(command = paste("mkdir ", scriptsOut, sep="")) # executing a shell command using R

for(currSet in indices){
  
  print(paste("####### making Picard script for sample", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], "#########"))
  
  bamDir <- paste0("/SAN/colcc/MMRd_HCEC_genomes/bam_files/", sampleList[currSet,"bam_file_loc"], sep="")
  
  inBam <- paste(bamDir, "/", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".sorted.bam", sep="")
  inBam2 <- paste(bamDir, "/", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".fixed.bam", sep="")
  
  outBamDub <- paste(bamDir, "/", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".mkdub.bam", sep="")
  outDubMetrics <- paste(bamDir, "/", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".mkdub.metrics.txt", sep="")
  
  runIDName <- paste0(sampleList[currSet, "clone"], sampleList[currSet, "subclone"], "_picard")
  
  errorfile <- paste0(streamOut, sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".", dateTag, ".out")
  
  outName <- paste0(scriptsOut, "runPicard_", sampleList[currSet, "clone"], sampleList[currSet, "subclone"], ".sh") 
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
TMP_DIR=", bamDir,"

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \\
INPUT=", inBam2," \\
OUTPUT=", outBamDub," \\
METRICS_FILE=", outDubMetrics," \\
CREATE_INDEX=true \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=", bamDir,"
                        
#build index file
samtools index ", outBamDub,"

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=", outBamDub," MODE=SUMMARY

rm ", inBam2, sep="")
      
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)

}






