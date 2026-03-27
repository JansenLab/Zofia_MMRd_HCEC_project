# 3.1.1.filterMutectCalls.R
# first created: 10/03/2021
# 
# 
# 
##################    notes    ################## 
# 
# 
# 
##################  libraries  ################## 

library(data.table)
library(scales)
library(ggplot2)
library(GGally)

################## main script ################## 

options(stringsAsFactors = FALSE)

# get date stamp
dateStamp <- date()
dateStamp <- strsplit(dateStamp, split = " ")[[1]]
dateStamp <- dateStamp[dateStamp!=""]
dateTag <- paste(dateStamp[c(3,2,5)], collapse = "")


#get sample list infomration
sampleList <- read.csv(file="C:/Users/lmck0/OneDrive/Documents/WGS/sampleList2.csv", header=TRUE, stringsAsFactors=FALSE)

# case IDs
caseIDs <- unique(sampleList[["setID"]]) # gathers all sample IDs

#directories
mutectDir <- "C:/Users/lmck0/OneDrive/Documents/WGS/"
filtDir <- "C:/Users/lmck0/OneDrive/Documents/WGS/"

driverTab <- read.csv(file="~/Projects/chondrosarcomasMetProject/0.1.referenceFiles/driverMutations.csv", header = TRUE)
driverTab <- driverTab[1:2, ]
driverTab[3, ] <- c("chr2", "208248389", "G", "C", "IDH1", "132")

# summary data tab
summTab <- data.frame(matrix(NA, nrow = nrow(sampleList), ncol = 5))
names(summTab) <- c("UID","brady", "SNVburden", "meanVAF", "meanDepth")
summTab["setID"] <- sampleList[["setID"]]



for(i in 1:length(caseIDs)){
  
  if(caseIDs[i] == 375438){
    next() # skip remaining elements of the loop
  }
  
  subSample <- sampleList[sampleList[["setID"]] %in% caseIDs[i], ] # selects consecutive sample IDs from a list of all unique sample IDs
  normalID <- subSample[subSample[["type"]]=="DNA PN", "brady"]
  
  # get mutect table
  vcfFile <- paste0(mutectDir, caseIDs[i], "/", caseIDs[i], "_filtered.vcf")
  
  dataIn <- fread(file=vcfFile, sep="\t", header = TRUE, skip = "#CHROM")
  dataIn <- as.data.frame(dataIn)
  names(dataIn)[1] <- c("CHROM")
  
  
  ############### filter based on standard flags ############### 
  dataIn <- dataIn[dataIn[["FILTER"]] %in% "PASS" | (dataIn[["CHROM"]] %in% driverTab[["chrom"]] & dataIn[["POS"]] %in% driverTab[["pos"]]), ]
  # retains variants that passed or variants that are hitting drivers (?)
  
  ############### reformat vcf table to get depths and VAFs ############### 
  
  # filter criteria
  # what do these mean?
  minDepthAll <- 20
  minVAFOne <- 0.05
  
  minDepthNormal <- 10
  maxVAFnorm <- 0.01
  
  # make new columns
  samList <- names(dataIn[10:ncol(dataIn)])
  
  dataIn[paste0(samList, "_DP")] <- NA
  dataIn[paste0(samList, "_VAF")] <- NA
  
  # sort fixed format variants
  # what is this for? I don't understand this series of unlist and strsplit
  formatLength <- nchar(dataIn[["FORMAT"]]) 
  normalFormatIndex <- which(formatLength == 24) # why is it 24?
  editFormatIndex <- which(formatLength != 24)
  
  for(bio in 1:length(samList)){
    depthVect  <- as.numeric(unlist(strsplit(dataIn[normalFormatIndex, samList[bio]], split = ":"))[seq(4, (7*length(normalFormatIndex)), 7)])
    # why 7???
    dataIn[normalFormatIndex, paste0(samList[bio], "_DP")] <- depthVect
    
    vafVect  <- unlist(strsplit(dataIn[normalFormatIndex, samList[bio]], split = ":"))[seq(3, (7*length(normalFormatIndex)), 7)]
    
    # catch instances with multiple reported vafs
    vafListMulti <- strsplit(vafVect, split = ",")
    changeIndex <- lengths(vafListMulti)
    indexSeq <- cumsum(changeIndex)
    
    vafListMulti <- unlist(vafListMulti)
    vafVect <- as.numeric(vafListMulti[indexSeq])
    
    dataIn[normalFormatIndex, paste0(samList[bio], "_VAF")] <- vafVect
  }
  
  dataIn["filterRes"] <- NA
  
  # make reporting vect
  reportNo <- round(seq(1, length(editFormatIndex), length.out = 100), digits = 0)
  
  # loop through non-standard formatted mutations and record depth and VAF
  # what does this non-standard formatting of mutations mean?
  for(curr in editFormatIndex){
    
    if(curr %in% reportNo){
      indexTemp <- which(curr == reportNo)
      print(paste0("######### progress: ", indexTemp, " % ##########"))
    }
    
    # get normal depth and VAF, mark filter accordingly
    normDPtemp <- as.numeric(strsplit(dataIn[curr, normalID], split = ":")[[1]][4])
    dataIn[curr, paste0(normalID, "_DP")] <-  normDPtemp
    
    if(normDPtemp < minDepthNormal){
      dataIn[curr, "filterRes"] <- "DPnorm"
      next()
    }else{
      
      # tumour depths
      depthVect <- c()
      for(bio in 1:length(samList)){
        depthVect[bio] <- as.numeric(strsplit(dataIn[curr, samList[bio]], split = ":")[[1]][4])
      }
      dataIn[curr, paste0(samList, "_DP")] <- depthVect
      
      if(TRUE %in% names(table(depthVect < minDepthAll)) ) {
        dataIn[curr, "filterRes"] <- "tumourDepth"
        next()
      }else{
        # normal VAFs
        normVAFtemp <- strsplit(dataIn[curr, normalID], split = ":")[[1]]
        normVAFtemp <- as.numeric(strsplit(normVAFtemp[3], split = ",")[[1]])
        normVAFtemp <- normVAFtemp[order(normVAFtemp)]
        dataIn[curr, paste0(normalID, "_VAF")] <-  normVAFtemp[1]
        
        # tumour VAFs
        vafVect <- c()
        for(bio in 1:length(samList)){
          tumVAFtemp <- strsplit(dataIn[curr, samList[bio]], split = ":")[[1]]
          tumVAFtemp <- as.numeric(strsplit(tumVAFtemp[3], split = ",")[[1]])
          vafVect[bio]  <- tumVAFtemp[order(tumVAFtemp)][1]
        }
        dataIn[curr, paste0(samList, "_VAF")] <- vafVect
      }
    }  
  }
  
  
  
  # save reformatted table
  dataTemp <- dataIn[is.na(dataIn[["filterRes"]]), ]
  dataTemp["filterRes"] <- "PASS"
  
  # mark up drivers
  dataTemp[dataTemp[["CHROM"]] %in% driverTab[["chrom"]] & dataTemp[["POS"]] %in% driverTab[["pos"]], "filterRes"] <- "driver"
  
  outputFile <- paste0(filtDir, caseIDs[i], "/", caseIDs[i], ".mutectCalls.filt.vcf")
  write.table(dataTemp, file=outputFile, sep="\t", row.names = FALSE)
  
  
  #record averahe depth, VAF, burden etc
  
  # check SNVs per sample
  snvTab <- dataTemp[dataTemp[["REF"]] %in% c("A", "C", "G", "T") & dataTemp[["ALT"]] %in% c("A", "C", "G", "T"), ]
  
  for(bio in 1:length(samList)){
    # SNV burden
    summTab[which(summTab[["brady"]] == samList[bio]), "SNVburden"] <- nrow(snvTab[snvTab[[paste0(samList[bio], "_VAF")]] >0 , ])
    
    # mean VAF
    summTab[which(summTab[["brady"]] == samList[bio]), "meanVAF"] <- mean(snvTab[[paste0(samList[bio], "_VAF")]])
    
    # mean VAF
    summTab[which(summTab[["brady"]] == samList[bio]), "meanDepth"] <- mean(snvTab[[paste0(samList[bio], "_DP")]])
  }
  
  # check average depth
  dpCounts <- c()
  for(bio in 1:length(samIDs)){
    tempVect <- snvTab[[paste0(samIDs[bio], "_DP")]]
    dpCounts[bio] <- mean(tempVect)
  }
  
  plotOut <- paste0(filtDir, caseIDs[i], "/", caseIDs[i], ".vafDis.pdf")
  pdf(file = plotOut, width = 10, height = 10)
  {
    for(bio in 1:length(samList)){
      if(samList[bio] == normalID){
        tag <- ":normal"
        plotCol <- "grey65"
      }else{
        tag <- ""
        plotCol <- "steelblue"
      }
      
      # SNV burden
      # what about indel burden? I thought Mutect2 returns that too
      plotDataTemp <- snvTab[snvTab[[paste0(samList[bio], "_VAF")]] >0 , paste0(samList[bio], "_VAF")]
      hist(x = plotDataTemp, breaks = seq(0,1,0.01), main = paste0("VAF distribution: ", samList[bio], tag),
           col=plotCol, border = "white", xlab = "VAF")
    }
  }
  dev.off()
  
  
  
}






