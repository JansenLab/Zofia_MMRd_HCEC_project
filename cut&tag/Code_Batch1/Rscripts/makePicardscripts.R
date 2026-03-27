# make Picard scripts according to CUT&TAG protocol: https://www.protocols.io/view/cut-amp-tag-data-processing-and-analysis-tutorial-e6nvw93x7gmk/?step=12.1

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# sample list
sample_sheet <- read.csv("/Users/zofiapiszka/Desktop/cut&tag/batch2/sample_list.csv")
samList <- sample_sheet$sample

# paths
scripts_loc <- "/Users/zofiapiszka/Desktop/cut&tag/batch2/code/picard/"
input_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output/"
report_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/reports/"
output_loc <- "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output2/"

for(sample in 1:length(samList)){
  
  print(paste("####### making Picard script for sample", samList[sample], "#########"))
  
  runIDName <- paste0(samList[sample], "_picard")
  errorfile <- paste0(report_loc, samList[sample], ".", dateTag, ".err")
  outLogfile <- paste0(report_loc, samList[sample], ".", dateTag, ".out")
  
  output_dir <- paste0(output_loc, samList[sample], "/")
  sam_file <- paste0(input_loc, samList[sample], ".bowtie2.sam")
  sorted_sam <- paste0(output_dir, samList[sample], ".bowtie2.sorted.sam")
  dupMarked <- paste0(output_dir, samList[sample], ".bowtie2.dupMarked.sam")
  metrics_file <- paste0(output_dir, samList[sample], "_picard.dupMark.txt")
  rmDup <- paste0(output_dir, samList[sample], "_bowtie2.sorted.rmDup.sam")
  metrics_file_rmDup <- paste0(output_dir, samList[sample], "_picard.rmDup.txt")
  
  outName <- paste0(scripts_loc, "runPicard_", samList[sample], ".sh") 
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=3:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N ",runIDName,"
#$ -e ",errorfile,"
#$ -o ",outLogfile,"

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

mkdir", output_dir, "
  
## Sort by coordinate
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar SortSam I=",sam_file,"O=",sorted_sam,"SORT_ORDER=coordinate

## mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I=",sorted_sam,"O=",dupMarked,"METRICS_FILE=",metrics_file, " \
                        
## remove duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I=",sorted_sam,"O=",rmDup,"REMOVE_DUPLICATES=true METRICS_FILE=",metrics_file_rmDup

)
  
  #write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
  
}
