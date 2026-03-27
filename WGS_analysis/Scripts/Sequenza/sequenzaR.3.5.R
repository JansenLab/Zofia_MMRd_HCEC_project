library("sequenza")
library("copynumber")

sampleList <- read.csv(file="/SAN/colcc/MMRd_CRC/sequenza/sampleList1.csv", header=TRUE, stringsAsFactors=FALSE)
setNames <- unique(sampleList[[1]])

seqFiles <- "/SAN/colcc/MMRd_HCEC_genomes/sequenza/output/"
# output <- "output"

# set analysis parameters
gammaParam <- 80
cellParam <- seq(0.75, 0.95, 0.05)
ploidyParam <- seq(0.8,5,0.1)

for(currSam in 1:nrow(sampleList)){
  
  #current set
  currID <- sampleList[currSam, "setID"]
  
  #read data from tumour seqz file name
  seqDirName <- paste(seqFiles, currID, sep="")
  
  # now set parameters based on sample 
  seqFileName <- paste(seqFiles, currID, "/", currID, ".seqz.binned.gz", sep="")
  extName <- paste(seqFiles, currID, "/", currID, ".extracted.RData", sep="")
  
  
  #analyze data using sequenza
  chromosomes <- paste("chr", c(1:22, "X"), sep="")
  seqzExt <- sequenza.extract(file=seqFileName, chromosome.list = chromosomes, gamma = gammaParam, kmin = 25, min.reads.baf = 20, assembly = "hg38")
  
  # save r object
  save(seqzExt, file=extName)
  
  #infer cellularity and ploidy
  paraSpace <- sequenza.fit(seqzExt, cellularity = cellParam, ploidy = ploidyParam)
  
  #sequenza analysis
  sequenza.results(sequenza.extract = seqzExt, cp.table = paraSpace, sample.id = currID, out.dir=seqDirName )
  
}
