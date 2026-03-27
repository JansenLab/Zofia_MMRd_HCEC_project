# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

#get sample list infomration
samList <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv", header=TRUE, stringsAsFactors=FALSE)

# get sample IDs
normalID <- sampleList[sampleList[["type"]]=="normal", "sample_id"] #how to do this?
samIDs <- unique(sampleList[["sample_id"]]) #is this correct?
# samIDs <- samIDs[samIDs != normalID] #remove normal id from the list; check if works

# file spaces
bamDir <- "/SAN/colcc/MMRd_HCEC_genomes/bam_files/" #BAM file directory
mutectDir <-  "/SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/persample/" #directory for Mutect2 output
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/" #Mutect2 reports folder

# genome resources
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"
sitesRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/af-only-gnomad.hg38.vcf.gz" 

# local file spaces
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Mutect2/runMutect_persample/" 

#output bam file list
bamListFileList <- paste(bamDir, samIDs, "/", samIDs, ".mkdub.bam", sep="")
bamListFileList <- paste("-I", bamListFileList, "\\")
# bamListFileList <- paste(bamListFileList, collapse = "
# ")

# normal bam
normalBam <- paste(bamDir, normalID, "/", normalID, ".mkdub.bam", sep="")
counter <- 1

# for each chromosome make a Mutect2 script
for (currChr in c(1:22, "X", "Y")){
  for (sample in samIDs) {
    
  # store new vcf name
  mutectVCFFile <- paste(mutectDir, "mutectCalls.chr", currChr, "_", sample, ".vcf", sep="")

  # regions parameter
  regionsString <- paste("-L chr", currChr, sep="") # -L - operate on specific genomic intervals
  
  runIDName <- paste0("runMutect_chr", currChr, "_", sample)
  
  errorfile <- paste0(streamOut, "mutect_chr", currChr, "_", sample, ".", dateTag, ".err")
  outLogfile <- paste0(streamOut, "mutect_chr", currChr, "_", sample, ".", dateTag, ".out")
  
  outName <- paste(scriptsOut, "/chr", currChr, "/runMutect_chr", currChr, "_", sample, ".sh", sep="") 
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
  
/share/apps/jdk-17.0.1/bin/java -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar Mutect2 \\
-R ", genomeRefFile," \\
", regionsString," \\
", bamListFileList[counter], "
-I ", normalBam," \\
-normal ", normalID," \\
--germline-resource ", sitesRefFile," \\
-O ", mutectVCFFile,"

", sep="")
  write(totalStrings, outName)
  counter <- counter + 1
  }
}
