# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# file and directory paths
sampleSheet <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv", header=TRUE, stringsAsFactors=FALSE)
samList <- sampleSheet[["sample_id"]]

mutectDir <-  "/SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/persample" #directory for Mutect2 output
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/mutect2/reports" #Mutect2 reports folder
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Mutect2/FilterMutectCalls_persample"

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

for (sample in samList) {
  VCF <- paste(mutectDir, "/mutectCalls.chr22.", sample, ".vcf", sep="")
  filtVCF <- paste(mutectDir, "filtered_vcf/mutectCalls.chr22.", sample, ".filtered.vcf", sep="")
  runIDName <- "runFiltMutect_persample"
  
  errorfile <- paste0(streamOut, "/filtMutect_", sample, ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, "/filtMutect_", sample, ".", dateTag, ".out")
  
  outName <- paste(scriptsOut, "/filterVCF.chr22.", sample, ".sh", sep="") 
  totalStrings <- paste("#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=120:0:0
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

/share/apps/jdk-17.0.1/bin/java -Xmx2g -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar FilterMutectCalls \\
-R ", genomeRefFile," \\
-V ", VCF," \\
-O ", filtVCF,"

", sep="")  
#write seq script file
  lapply(totalStrings, write, outName, append=FALSE)
}