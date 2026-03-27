# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# file and directory paths
mutectDir <-  "/SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files" #directory for Mutect2 output
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/mutect2/reports" #Mutect2 reports folder
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Mutect2/FilterMutectCalls"

genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"

VCF <- paste(mutectDir, "/mutectCalls.chr2.vcf", sep="")
filtVCF <- paste(mutectDir, "/mutectCalls.chr2.filtered.vcf", sep="")
runIDName <- "runFiltMutect"

errorfile <- paste0(streamOut, "/filtMutect_", dateTag, ".err")
outLogfile <- paste0(streamOut, "/filtMutect_", dateTag, ".out")

outNameMerge <- paste(scriptsOut, "/filterVCF.chr2.sh", sep="") 
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

/share/apps/jdk-17.0.1/bin/java -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar FilterMutectCalls \\
-R ", genomeRefFile," \\
-V ", VCF," \\
-O ", filtVCF,"

", sep="")  

#write seq script file
write(totalStringsMerge, file = outNameMerge)