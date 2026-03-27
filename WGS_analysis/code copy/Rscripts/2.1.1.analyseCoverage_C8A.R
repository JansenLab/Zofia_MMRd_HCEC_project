# 1.5.1.analyseCoverage.R
# part of the variant calling best practices
# /data/BCI-EvoCa/william/referenceHG19/nexterarapidcapture_exome_UNIX.interval_list
#
###### notes #######
#
# example: 
# Rscript ~/Code/bestPractices/1.5.1.analyseCoverage.R ~/Projects/glandSeqProject/sampleList.csv /data/BCI-EvoCa2/wchc/glandSeqProject/2.processedBams/ ~/Projects/glandSeqProject/runScripts/
#
#
# Process:
# 1.make and run 1.5.0.makeCoverageScripts scripts on Apocrita
#   |
#   V
# 2.download coverage files
#   |
#   V
# 3.run 1.5.1.analyseCoverage.R on Locally
#
#
###### begin ########


# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")


#get arguments from script
# arguments <- commandArgs(trailingOnly = TRUE)

#check number of arguments
#if(length(arguments)!=3){
#  stop("\n#### arguments > 1.5.1.analyseCoverage.R <sample list file> <coverageDir> ####\n")
#}

#get sample list information
# sampleListMain <- read.csv(file="/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/sample_sheet_simplified.csv", header=TRUE, stringsAsFactors=FALSE)

method <- "genomes"
#method <- "LPWGS"

#subset for particular run
#runID <- "F21_1001"
#sampleListMain <- sampleListMain[sampleListMain[["sampleInfo"]]==runID, ]
# runIDs <- unique(sampleListMain[["brady"]])
libType <- "WGS"

#coverageDir <- "~/Projects/glandSeqProject/1.5.coverageStats/exomes/"
coverageDir <- paste("/Users/zofiapiszka/Desktop/wgs_crispr_all_clones/coverage_files/HC_merged", sep="")
#coverageDir <- arguments[2]

#subset by run
#runIDs <- unique(sampleListMain[["sampleInfo"]])

#make stats table
#statsTab <- data.frame(matrix(NA, nrow = nrow(sampleListMain), ncol = 7)) # creates a matrix filled with NA values
# will have to change that to go by every second row 
# names(statsTab) <- c("C8A.nfm", "meanDepth", "meanCoverage", "duplicatedReads", "totalPercRem")
# statsTab["sample_id"] <- sampleListMain[["sample_id"]]

# statsTab["location"] <- sampleListMain[["location"]] # what is this supposed to be?


#plotCounter <- 1


pdf(file=paste(coverageDir, "_", "alignmentSummary.", dateTag,".pdf", sep=""), width = 6, height = 2)
par(mfrow=c(1, 3), mar=c(4,4,4,4), cex=0.5) # set graphical parameters 
  
  plotNames <- "C8A.nfm" # do I need this?
  # plotNames is like my clone-subclone; how to make it add values of two columns (clone and subclone) to one variable (plotNames)?

  #get insert metrics file
  metricsTemp <- read.table(file = paste(coverageDir, "/", "HC_merged", ".insert_metrics.txt", sep=""), sep="\t", header = TRUE, fill = TRUE, stringsAsFactors = FALSE)
  insetTable <- metricsTemp[3:nrow(metricsTemp), 1:2]
  insetTable[1] <- as.numeric(insetTable[[1]], na.rm=TRUE)
  insetTable[2] <- as.numeric(insetTable[[2]], na.rm=TRUE)
  names(insetTable) <- c("insert_size", "All_Reads.fr_count")

  # batchStr <- statsTab[currSet, "sampleID"] # probably won't need this new identifier if I have plotNames accounting for both clone and subclone
  
  barplot(as.numeric(insetTable[["All_Reads.fr_count"]]), 
          las=2, width = 1, border = "darkred", main=paste(plotNames, "\n insert size distribution"),
          xlim = c(0, 600), xlab="insert size (bp)")
  axis(side = 1, at = seq(0, 500, 100), labels = seq(0, 500, 100))
  
  mtext(text = paste("library:", libType), cex = 0.5)
  text(x = 100, y = (IQR(insetTable[["All_Reads.fr_count"]], na.rm = TRUE)*1.5), labels = paste("mean insert = 
", round(metricsTemp[1, "MEAN_INSERT_SIZE"], digits = 2)), xpd=TRUE)
  
  
  #get sequence metrics file
  seqMetricTemp <- read.table(file = paste(coverageDir, "/", "HC_merged", ".seq_metrics.txt", sep=""), sep="\t", header = TRUE, fill = TRUE, stringsAsFactors = FALSE)
  
  
  insetMetTable <- data.frame(matrix(ncol = 2, nrow = 15, NA))
  names(insetMetTable) <- c("coverage", "percBases")
  insetMetTable["coverage"] <- c(0,1,5,10,15,20,25,30,40,50,60,70,80,90,100)
  insetMetTable["percBases"] <- c(1, as.numeric(seqMetricTemp[1, 14:27])) # why 14:27? do I have to adjust it to my own samples?
  
  
  plot(x = insetMetTable[["coverage"]], y = insetMetTable[["percBases"]], 
         pch=20, xlab = "sequencing depth", ylab = "% targeted bases", 
         main = "% library targets vs depth", frame.plot = FALSE, ylim = c(0,1))
  
  lines(x = insetMetTable[["coverage"]], y = insetMetTable[["percBases"]], col="blue") # adds a line that connects coverage points every 10%
  segments(x0 = 0, y0 = insetMetTable[5, "percBases"], x1 = 15, y1 = insetMetTable[5, "percBases"], col="grey60")
  segments(x0 = 15, y0 = 0, x1 = 15, y1 = insetMetTable[5, "percBases"], col="grey60")
  text(x = (max(insetMetTable[["coverage"]])/2), y = 0.9, labels = paste("mean depth = ", round(as.numeric(seqMetricTemp[1, "MEAN_COVERAGE"]), digits = 2)), xpd=TRUE)
  text(x = (max(insetMetTable[["coverage"]])/2), y = 1, labels = paste("% covered by >=15X = ", round(insetMetTable[5, "percBases"], digits = 2)), xpd=TRUE)
  
  
  ####### record data ########
  
  # statsTab[plotCounter, "meanDepth"] <- as.numeric(seqMetricTemp[1, "MEAN_COVERAGE"])
  
  #get alignment metrics file
  alignmentTemp <- read.table(file = paste(coverageDir, "/", "HC_merged", ".alignment_metrics.txt", sep=""), sep="\t", header = TRUE, stringsAsFactors = FALSE) # edit 
  
  # statsTab[plotCounter, "totalPercRem"] <- round(seqMetricTemp[1, "PCT_EXC_TOTAL"], digits = 2)
 # plotCounter <- plotCounter + 1 
  
  plot(c(1,1), type="n", axes=F, xlab="", ylab="", main="alignment statistics")
  text(x = 0.8, y = 1.4, labels = paste("total alignments (individual) =", alignmentTemp[3, "TOTAL_READS"]), xpd=TRUE, pos = 4)
  theoCover <- round((as.numeric(alignmentTemp[3, "TOTAL_READS"]) * as.numeric(alignmentTemp[3, "MEAN_READ_LENGTH"])) / as.numeric(seqMetricTemp[1, "GENOME_TERRITORY"]), digits = 3)
  text(x = 0.8, y = 1.3, labels = paste("theoretical depth =", theoCover), xpd=TRUE, pos = 4)
  
  text(x = 0.8, y = 1.2, labels = paste("% bases >Q20 =", round(as.numeric(alignmentTemp[3, "PF_HQ_ALIGNED_Q20_BASES"]) / alignmentTemp[3, "PF_ALIGNED_BASES"], digits = 2)), xpd=TRUE, pos = 4)
  tempValue <- round(as.numeric(alignmentTemp[3, "PF_HQ_ALIGNED_READS"]) / alignmentTemp[3, "TOTAL_READS"], digits = 2)
  text(x = 0.8, y = 1.1, labels = paste("% alignments >Q20 =", tempValue), xpd=TRUE, pos = 4)
  text(x = 0.8, y = 1, labels = paste("mean read length =", round(alignmentTemp[3, "MEAN_READ_LENGTH"], digits = 2)), xpd=TRUE, pos = 4)
  text(x = 0.8, y = 0.9, labels = paste("% total filt (dup / MQ / off-target) =", round(seqMetricTemp[1, "PCT_EXC_TOTAL"], digits = 2)), xpd=TRUE, pos = 4)
  text(x = 0.8, y = 0.8, labels = paste("% filtered (BQ) =", round(seqMetricTemp[1, "PCT_EXC_BASEQ"], digits = 2)), xpd=TRUE, pos = 4)
  text(x = 0.8, y = 0.7, labels = paste("% filtered (read overlap) =", round(seqMetricTemp[1, "PCT_EXC_OVERLAP"], digits = 2)), xpd=TRUE, pos = 4)
  

dev.off()



# write stats table
# write.table(statsTab, file = paste(coverageDir,"_", "alignmentStats.", dateTag, ".tsv", sep=""), quote = FALSE, sep = "\t", row.names = FALSE)





