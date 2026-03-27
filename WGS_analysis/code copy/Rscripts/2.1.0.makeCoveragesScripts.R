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
# if(length(arguments)!=4){
#  stop("\n#### arguments > 2.1.0.makeCoverageScripts.R <sample list file> <bamDir> <covOut> <scriptsOut> ####\n")
# }

#get sample list infomration
#sampleList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv", header=TRUE, stringsAsFactors=FALSE)

# make the list of indices to iterate over every second row in the sample list
#indices <- seq(1, nrow(sampleList), by = 2)
sampleList <- c("HCEC-MC", "MLH1-A6-PC")

#subset
# runID <- ""
#sampleList <- sampleList[sampleList[["sampleInfo"]]==runID, ]


# bamDir <- paste0(sampleList[1,"analysisLoc"], "2.0.bamFiles/", sep="")
# bamDir <- arguments[2]

outDir <- "/SAN/colcc/MMRd_HCEC_genomes/coverage_files/"
# outDir <- arguments[3]

localDir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/runCoverage/"

streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/picard/reports/coverage_metrics/"

bamTag <- ".mkdub.bam"
#bamTag <- ".sorted.bam"

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

#system(command = paste("mkdir ", localDir, sep=""))

for(currSet in 1:length(sampleList)){
  
  print(paste("####### making coverage script for sample", sampleList[currSet], "#########"))
  
  bamDir <- paste0("/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files", sep="")
  
  inputBam <- paste(bamDir, "/", sampleList[currSet], ".mkdub.bam", sep="")
  outCovFile <- paste(outDir, sampleList[currSet], "/", sampleList[currSet], sep="")
  
  runIDName <- paste0(sampleList[currSet], "_picard")
  
  errorfile <- paste0(streamOut, sampleList[currSet], ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, sampleList[currSet], ".", dateTag, ".out")
  
  outName <- paste0(localDir, "2.1.0.runCoverage_", sampleList[currSet], ".sh")
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=24:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

module load R

#get general sequence metrics
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectWgsMetrics \\
I=", inputBam," \\
O=", outCovFile, ".seq_metrics.txt \\
R=", genomeRefFile, " \\
COVERAGE_CAP=10000 \\
MAX_RECORDS_IN_RAM=100000 \\
TMP_DIR=", outDir, sampleList[currSet],"

#collect stats specific to interval size including a histogram
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectInsertSizeMetrics \\
I=", inputBam, " \\
O=", outCovFile, ".insert_metrics.txt \\
H=", outCovFile, ".insert_hist.pdf \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=", outDir, sampleList[currSet],"

#get general alignment stats such as % reads aligned
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectAlignmentSummaryMetrics \\
I=", inputBam, " \\
O=", outCovFile, ".alignment_metrics.txt \\
R=", genomeRefFile, " \\
MAX_RECORDS_IN_RAM=1000000 \\
TMP_DIR=", outDir, sampleList[currSet],"
"
, sep="")
      
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)

}

