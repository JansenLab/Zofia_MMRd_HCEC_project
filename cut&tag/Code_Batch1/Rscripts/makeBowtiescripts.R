# make Bowtie2 scripts to run alignment of CUT&TAG data
# replicating Claudia's script

# paths
fastq_list <- read.csv("/Users/zofiapiszka/Desktop/cut&tag/batch2/fastq_list.csv", header = FALSE)
fastq_stripped <- lapply(fastq_list$V1, function(x) strsplit(x, "/")[[1]][2])

sample_list <- read.csv("/Users/zofiapiszka/Desktop/cut&tag/batch2/sample_list.csv")
samList <- sample_list$sample

scripts_loc <- "/Users/zofiapiszka/Desktop/cut&tag/batch2/code/bowtie/"
input_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming/output/"
report_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/reports/"
output_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output/"
genomeRefFile <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/bowtie2_human_ref_genome"

# date tag
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# make Bowtie scripts
readString <- c("_1", "_2")

for(i in 1:length(samList)){ #edit
  
  print(paste("####### making Bowtie script for sample:", samList[i], "#########"))
  
  # fastq files
  inputfileF <- paste0(input_loc, fastq_stripped[[i]], readString[1], ".trimmed.fq.gz")
  inputfileR <- paste0(input_loc, fastq_stripped[[i]], readString[2], ".trimmed.fq.gz")
  
  # specify log and error out files
  errorFile <- paste0(report_loc, samList[i], ".", dateTag, ".err")
  outLogFile <- paste0(report_loc, samList[i], ".", dateTag, ".out")
  
  outputFile <- paste(output_loc, samList[i], ".bowtie2.sam", sep="")

  outName <- paste0(scripts_loc, "runBowtie_", samList[i], ".sh") 
  runIDName <- paste0(samList[i], "_bowtie")
  
  # one script for each pair (forward & reverse)
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N", runIDName,"
#$ -e", errorFile,"
#$ -o", outLogFile,"

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

echo reads in", samList[i], "fastq:
zcat", inputfileF," | echo $((`wc -l`/4))

echo reads in", samList[i], "fastq:
echo $(( $(zcat", inputfileF, "| wc -l) / 4 ))

bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 12 -x", genomeRefFile, "-1", inputfileF, "-2", inputfileR, "-S", outputFile 

)
  
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
}