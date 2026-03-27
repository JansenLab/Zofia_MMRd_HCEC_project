# make Sequenza bash scripts that make .seqz files #

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")

# get sample list
samList <- read.csv("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet.csv")
crispr1 <- samList$sample_id[c(3:18, 31)]
crispr2 <- samList$sample_id[19:30]

# paths
bamDir <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files"
outDir <- "/SAN/colcc/MMRd_HCEC_genomes/sequenza/"
streamOut <- "/SAN/colcc/MMRd_HCEC_genomes/sequenza/reports"
scriptsOut <- "/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/code/Sequenza/makeSeqz"
genomeRefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa"
gc50_RefFile <- "/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.gc50base.txt"

normalBam <- "/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam"

# Construct the script content as a single string
for (sample in crispr1) {
  
  # sample-specific arguments
  outName <- paste0(scriptsOut, "/makeSeqz.", sample, ".sh")
  runIDName <- paste0(sample, "_makeSeqz")
  errorLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".err")
  outLogFile <- paste0(streamOut, "/", sample, ".", dateTag, ".out")
  
  tumourBam <- paste0(bamDir, "/", sample, ".mkdub.bam")  
  runDir <- paste0(outDir, "output/", sample, "/")
  
  # Construct the script content as a single string
  scripts <- paste0("#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=80:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N ", runIDName,"
#$ -e ", errorLogFile,"
#$ -o ", outLogFile,"

export PATH=/share/apps/python-3.9.5-shared/bin/:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.9.5-shared/lib/:$LD_LIBRARY_PATH

#make analysis dir
mkdir ", runDir,"

#get .seqz file
sequenza-utils bam2seqz -gc ", gc50_RefFile, " --fasta ",  genomeRefFile, " -n ", normalBam, " -t ", tumourBam , " -o ", runDir, sample, ".seqz.gz

#bin .seqz file to shorten analysis time
sequenza-utils seqz_binning -w 250 -s ", runDir, sample, ".seqz.gz -o ", runDir, sample, ".seqz.binned.gz --tabix tabix-0.2.6/

chmod 777 ", runDir, sample, ".seqz.gz
chmod 777 ", runDir, sample, ".seqz.binned.gz

#run pre-processed files using sequenza in R locally"
  )
  
  # Write the script content to a file
  write(scripts, file = outName)
}
