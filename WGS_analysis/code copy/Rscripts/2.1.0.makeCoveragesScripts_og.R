# 1.5.0.makeCoverageScripts.R
# part of the variant calling best practices
# /data/BCI-EvoCa/william/referenceHG19/nexterarapidcapture_exome_UNIX.interval_list
#
###### notes #######
#
# example: 
# Rscript ~/Code/bestPractices/1.5.0.makeCoverageScripts.R ~/Projects/glandSeqProject/sampleList.csv /data/BCI-EvoCa2/wchc/glandSeqProject/2.processedBams/ ~/Projects/glandSeqProject/runScripts/
#
#
# Process:
# 1.make and run 1.5.0.makeCoverageScripts.R scripts on1 Apocrita
#   |
#   V
# 2.download coverage files
#   |
#   V
# 3.run 2.1.0.makeCoverageScripts.R on Locally
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
if(length(arguments)!=4){
  stop("\n#### arguments > 2.1.0.makeCoverageScripts.R <sample list file> <bamDir> <covOut> <scriptsOut> ####\n")
}

#get sample list infomration
sampleList <- read.csv(file="~/Projects/chondrosarcomasMetProject/0.0.sampleLists/0.sampleList.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
samIDs <- unique(sampleList[["brady"]])

#subset
runID <- ""
#sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]


bamDir <- paste0(sampleList[1,"analysisLoc"], "2.0.bamFiles/", sep="")
bamDir <- arguments[2]

outDir <- paste0(sampleList[1,"analysisLoc"], "2.0.bamFiles/2.1.0.coverageFiles/", sep="")
outDir <- arguments[3]

localDir <- "~/Projects/chondrosarcomasMetProject/0.0.code/sh/2.1.0.runCoverage/"

streamOut <- "/SAN/colcc/sarc_amf/0.0.code/reports/2.0.1.makeCoverage/"

bamTag <- ".mkdub.bam"
#bamTag <- ".sorted.bam"

system(command = paste("mkdir ", localDir, sep=""))

for(currSet in 1:nrow(sampleList)){
  
  print(paste("####### making coverage script for sample", sampleList[currSet, "sampleID"], "#########"))
  
  inputBam <- paste(bamDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], ".mkdub.bam", sep="")
  outCovFile <- paste(outDir, sampleList[currSet, "brady"], "/", sampleList[currSet, "brady"], sep="")
  
  runIDName <- paste0(sampleList[currSet, "brady"], "_picard")
  
  errorfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet, "brady"], ".", dateTag, ".out")
  
  outName <- paste0(localDir, "2.1.0.runCoverage_", sampleList[currSet, "brady"], ".sh")
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

module load R

mkdir ", outDir, sampleList[currSet, "brady"],"

#get general sequence metrics
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectWgsMetrics \\
I=", inputBam," \\
O=", outCovFile, ".seq_metrics.txt \\
R=", genomeRefFile, " \\
COVERAGE_CAP=10000 \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=/SAN/colcc/sarc_amf/2.0.bamFiles/

#collect stats specific to interval size including a histogram
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectInsertSizeMetrics \\
I=", inputBam, " \\
O=", outCovFile, ".insert_metrics.txt \\
H=", outCovFile, ".insert_hist.pdf \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=/SAN/colcc/sarc_amf/2.0.bamFiles/

#get general alignment stats such as % reads aligned
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectAlignmentSummaryMetrics \\
I=", inputBam, " \\
O=", outCovFile, ".alignment_metrics.txt \\
R=", genomeRefFile, " \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=/SAN/colcc/sarc_amf/2.0.bamFiles/
"
, sep="")
      
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)

}

