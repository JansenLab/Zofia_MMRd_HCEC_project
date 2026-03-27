# 3.1.0.makeMutectScripts.R
# part of the variant calling best practices
#
###### notes #######
#
# makes one script for each chromosome
# 
# running in multi-region / sample mode
# 
###### begin ########

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

#get sample list infomration
sampleList <- read.csv(file="C:/Users/lmck0/OneDrive/Documents/WGS/sampleList.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
normalID <- sampleList[sampleList[["type"]]=="NORMAL", "setID"] #how to do this?
samIDs <- unique(sampleList[["setID"]])

# cluster file spaces
bamDir <- paste0(sampleList[1,"analysisLoc"])
mutectDir <-  paste0(sampleList[1,"analysisLoc"], "/mutect2/", sep="")
localMutectDir <- "C:/Users/lmck0/OneDrive/Documents/WGS/Mutect2"
streamOut <- "/SAN/colcc/MMRd_CRC/reports/mutect2"

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"
sitesRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/af-only-gnomad.hg38.vcf.gz"


# local file spaces
scriptsOut <- "C:/Users/lmck0/OneDrive/Documents/WGS/Scripts"

#output bam file list
bamTopDir <- paste0(bamDir, "/")
bamListFileList <- paste(bamTopDir, samIDs, ".mkdub.bam", sep="")
bamListFileList <- paste("-I", bamListFileList, "\\")
bamListFileList <- paste(bamListFileList, collapse = "
")

# normal bam
normalBam <- paste(bamDir, ".mkdub.bam", sep="")

vcfFiles <- c()
vcfCounter <- 1

# for each chromosome make a platypus calling script
for(currChr in c(1:22, "X", "Y")){

  # store new vcf name
  mutectVCFFile <- paste(mutectDir, "3.1.0.mutectCalls.chr", currChr,".vcf", sep="")
  vcfFiles[vcfCounter] <- mutectVCFFile
  vcfCounter <- vcfCounter + 1
  
  # regions parameter
  regionsString <- paste("-L chr", currChr, sep="")
  
  runIDName <- paste0("runMutect_chr", currChr)
  
  errorfile <- paste0(streamOut, "/mutect_chr", currChr, ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, "/mutect_chr", currChr, ".", dateTag, ".out")
  
  outName <- paste(scriptsOut, "3.1.0.runMutect_chr", currChr, ".sh", sep="") 
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
  

./jdk1.8.0_131/bin/java -jar /share/apps/genomics/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar Mutect2 \\
-R ", genomeRefFile," \\
", regionsString," \\
", bamListFileList, "
-I ", normalBam," \\
-normal ", normalID," \\
--germline-resource ", sitesRefFile," \\
-O ", mutectVCFFile,"

", sep="")
  lapply(totalStrings, write, outName, append=FALSE)
}
  
  




#make vcf merging script
mergedVCF <- paste(mutectDir, "peace.merged.vcf", sep="")
runIDName <- "runMergeMutect"

errorfile <- paste0(streamOut, "mergeMutect_", dateTag, ".err")
outLogfile <- paste0(streamOut, "mergeMutect_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "3.1.merge_finalVCF.sh", sep="") 
totalStringsMerge <- paste("#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=120:0:0
#$ -pe smp 1
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

./jdk1.8.0_131/bin/java -jar /share/apps/genomics/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar MergeVcfs ", paste("-I", vcfFiles, collapse = " "), " -O ", mergedVCF,"

", sep="")   

#write seq script file
lapply(totalStringsMerge, write, outNameMerge, append=FALSE)
  



#make stats merging script
mergedStats <- paste(mutectDir, "peace.merged.stats", sep="")
runIDName <- "runMergeStats"

errorfile <- paste0(streamOut, "mergeStats_", dateTag, ".err")
outLogfile <- paste0(streamOut, "mergeStats_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "3.1.merge_VCFstats.sh", sep="") 
totalStringsMerge <- paste("#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=120:0:0
#$ -pe smp 1
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

./jdk1.8.0_131/bin/java -jar /share/apps/genomics/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar MergeMutectStats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr1.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr2.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr3.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr4.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr5.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr6.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr7.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr8.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr9.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr10.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr11.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr12.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr13.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr14.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr15.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr16.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr17.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr18.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr19.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr20.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr21.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr22.vcf.stats \\
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chrX.vcf.stats \\
-O /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/peace.merged.vcf.stats

", sep="")   

#write seq script file
lapply(totalStringsMerge, write, outNameMerge, append=FALSE)



#make vcf filtering script (no segment, no contamination table)
mergedVCF <- paste(mutectDir, "peace.merged.vcf", sep="")
filtVCF <- paste(mutectDir, "peace.filtered.vcf", sep="")
runIDName <- "runFiltMutect"

errorfile <- paste0(streamOut, "filtMutect_", dateTag, ".err")
outLogfile <- paste0(streamOut, "filtMutect_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "3.1.filterVCF.sh", sep="") 
totalStringsMerge <- paste("#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=120:0:0
#$ -pe smp 1
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

./jdk1.8.0_131/bin/java -jar /share/apps/genomics/gatk-4.1.2.0/gatk-package-4.1.2.0-local.jar FilterMutectCalls \\
-R ", genomeRefFile," \\
-V ", mergedVCF," \\
-O ", filtVCF,"

", sep="")   

#write seq script file
lapply(totalStringsMerge, write, outNameMerge, append=FALSE)




# make pileup files and contamination tables (used to improve filtering)
runIDName <- "makePileup"
bamTopDir <- paste0(bamDir, samList, "/")
bamFileListAll <- paste(bamTopDir, samList, ".final.bam", sep="")

for(curr in 1:length(samList)){
  
  errorfile <- paste0(streamOut, "makePileup_", samList[curr], "_", dateTag, ".err")
  outLogfile <- paste0(streamOut, "makePileup_", samList[curr], "_", dateTag, ".out")
  
  pileupTableTemp <- paste(bamDir, samList[curr], "/", samList[curr], ".final.pileups.table", sep="")
  contaminationTableTemp <- paste(bamDir, samList[curr], "/", samList[curr], ".contamination.table", sep="")
  
  
  outNameMerge <- paste(scriptsOut, "3.1.makePileup_", samList[curr], ".sh", sep="") 
  totalStringsMerge <- paste("#$ -S /bin/bash
#$ -l tmem=25G
#$ -l h_vmem=25G
#$ -l h_rt=120:0:0
#$ -pe smp 1
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorfile,"
#$ -o ", outLogfile,"

/share/apps/genomics/gatk-4.1.2.0/gatk --java-options \"-Xmx18G\" GetPileupSummaries \\
-I ", bamFileListAll[curr]," \\
-O ", pileupTableTemp," \\
-V ", sitesRefFile, " \\
-L ", sitesRefFile, " \\

#/share/apps/genomics/gatk-4.1.2.0/gatk --java-options \"-Xmx18G\" CalculateContamination \\
#-I ", pileupTableTemp," \\
#-matched /SAN/colcc/sarc_amf/2.0.bamFiles/S00070763/S00070763.final.pileups.table \\
#-O ", contaminationTableTemp,"

", sep="")   
  
  #write seq script file
  lapply(totalStringsMerge, write, outNameMerge, append=FALSE)
  
}



