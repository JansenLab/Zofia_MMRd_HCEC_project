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
sampleList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/wgs_master_file.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
normalID <- sampleList[sampleList[["type"]]=="normal", "sample_id"] #how to do this?
samIDs <- unique(sampleList[["sample_id"]]) #is this correct?
samIDs <- samIDs[samIDs != normalID] #remove normal id from the list; check if works

# cluster file spaces
bamDir <- "/SAN/colcc/MMRd_HCEC_genomes/bam_files/" #BAM file directory
mutectDir <-  "/SAN/colcc/MMRd_HCEC_genomes/bam_files/mutect2" #directory for Mutect2 output
localMutectDir <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Mutect2" 
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/mutect2/reports" #Mutect2 reports folder

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"
sitesRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/af-only-gnomad.hg38.vcf.gz" #this is still the most up-to-date gnomad?


# local file spaces
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Mutect2"

#output bam file list
bamTopDir <- paste0(bamDir, "/")
bamListFileList <- paste(bamTopDir, samIDs, ".mkdub.bam", sep="")
bamListFileList <- paste("-I", bamListFileList, "\\")
bamListFileList <- paste(bamListFileList, collapse = "
")

# normal bam
normalBam <- paste(bamDir, ".mkdub.bam", sep="") # how is that making a normal bam filepath?

vcfFiles <- c()
vcfCounter <- 1

# for each chromosome make a platypus calling script #Mutect2 script, platypus is a mistake here
for(currChr in c(1:22, "X", "Y")){

  # store new vcf name
  mutectVCFFile <- paste(mutectDir, "mutectCalls.chr", currChr,".vcf", sep="")
  vcfFiles[vcfCounter] <- mutectVCFFile
  vcfCounter <- vcfCounter + 1
  
  # regions parameter
  regionsString <- paste("-L chr", currChr, sep="") # -L - operate on specific genomic intervals
  
  runIDName <- paste0("runMutect_chr", currChr)
  
  errorfile <- paste0(streamOut, "/mutect_chr", currChr, ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, "/mutect_chr", currChr, ".", dateTag, ".out")
  
  outName <- paste(scriptsOut, "runMutect_chr", currChr, ".sh", sep="") 
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
#should I change this to 4.4.0.0?
#gatk-4.4.0.0 needs java 17
-R ", genomeRefFile," \\
", regionsString," \\
", bamListFileList, " # why is a bam file a reference here? I thought it's an input
# -I sampleBam?
-I ", normalBam," \\ # how will this look for joint calling?
-normal ", normalID," \\
--germline-resource ", sitesRefFile," \\
# --f1r2-tar-gz # for read orientation bias?
-O ", mutectVCFFile,"

", sep="")
  lapply(totalStrings, write, outName, append=FALSE)
}
  
  
# calculate contamination?
# learn orientation bias artifacts?

# gatk LearnReadOrientationModel \ 
# -I f1r2.tar.gz \ 
# -O artifact-prior.tar.gz


#make vcf merging script
mergedVCF <- paste(mutectDir, "peace.merged.vcf", sep="") # what does "peace" stand for here?
runIDName <- "runMergeMutect"

errorfile <- paste0(streamOut, "mergeMutect_", dateTag, ".err")
outLogfile <- paste0(streamOut, "mergeMutect_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "merge_finalVCF.sh", sep="") 
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
# update version
", sep="")   

#write seq script file
lapply(totalStringsMerge, write, outNameMerge, append=FALSE)
  



#make stats merging script
mergedStats <- paste(mutectDir, "peace.merged.stats", sep="")
runIDName <- "runMergeStats"

errorfile <- paste0(streamOut, "mergeStats_", dateTag, ".err")
outLogfile <- paste0(streamOut, "mergeStats_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "merge_VCFstats.sh", sep="") 
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
#update version
-stats /SAN/colcc/sarc_amf/3.0.variantCalling/3.1.mutect/3.1.0.mutectCalls.chr1.vcf.stats \\ #why are these files in sarc_amf? shouldn't they be in Lauren's folder?
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



#make vcf filtering script (no segment, no contamination table) # what does "no segment" mean here?
VCF <- paste(mutectDir, ".vcf", sep="")
filtVCF <- paste(mutectDir, ".filtered.vcf", sep="")
runIDName <- "runFiltMutect"

errorfile <- paste0(streamOut, "filtMutect_", dateTag, ".err")
outLogfile <- paste0(streamOut, "filtMutect_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "filterVCF.sh", sep="") 
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
#update version
-R ", genomeRefFile," \\
-V ", mergedVCF," \\
-O ", filtVCF,"

", sep="")   # why is there no adjusting of filters here? where is LOD etc?

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
  
  
  outNameMerge <- paste(scriptsOut, "makePileup_", samList[curr], ".sh", sep="") 
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
#update versions
-I ", bamFileListAll[curr]," \\
-O ", pileupTableTemp," \\
-V ", sitesRefFile, " \\
-L ", sitesRefFile, " \\

#/share/apps/genomics/gatk-4.1.2.0/gatk --java-options \"-Xmx18G\" CalculateContamination \\
#update versions
#-I ", pileupTableTemp," \\
#-matched /SAN/colcc/sarc_amf/2.0.bamFiles/S00070763/S00070763.final.pileups.table \\ #why sarc_amf again?
#-O ", contaminationTableTemp,"

", sep="")   
  
  #write seq script file
  lapply(totalStringsMerge, write, outNameMerge, append=FALSE)
  
}



