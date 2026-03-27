rm(list=ls())
library(ASCAT)
library(doParallel)
library(Battenberg)
setwd("/home/regmars/Scratch/CCS_batch6/Battenberg/")
listdata <- read.delim2(file="battenberg_batch6.csv", header=TRUE, sep=",")
for (i in 1:nrow(listdata)){
  batchfolder <- listdata[i,1]
  TUMOURNAME <- listdata[i,2]
  NORMALNAME <- listdata[i,3]
  TUMOURBAM = paste("/home/regmars/Scratch/CCS_batch6/bam/",TUMOURNAME,"-ready.bam",sep="")
  NORMALBAM = paste("/home/regmars/Scratch/CCS_batch6/bam/",NORMALNAME,"-ready.bam",sep="")
  RUN_DIR = paste("/home/regmars/Scratch/CCS_batch6/Battenberg/",batchfolder,sep="")
  print(TUMOURBAM)
  print(NORMALBAM)
  print(RUN_DIR)
  if (listdata[i,4] == 'M'){
    ismaleinfo <- TRUE
  } else{
    ismaleinfo <- FALSE
  }
  NTHREADS = 6
  analysis = "paired"
  JAVAJRE = "java"
  ALLELECOUNTER = "/home/regmars/Scratch/softwares/packages/alleleCounter/bin/alleleCounter"
  IMPUTE_EXE = "impute2"
  BEAGLE_BASEDIR = "/home/regmars/Scratch/softwares/Battenberg_reference"
  GENOMEBUILD = "hg38"
  IMPUTEINFOFILE = file.path(BEAGLE_BASEDIR, "impute_info.txt")
  G1000ALLELESPREFIX = file.path(BEAGLE_BASEDIR, "1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_allele_index_")
  G1000LOCIPREFIX = file.path(BEAGLE_BASEDIR, "1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_loci_")
  GCCORRECTPREFIX = file.path(BEAGLE_BASEDIR, "GC_correction_hg38/1000G_GC_")
  REPLICCORRECTPREFIX = file.path(BEAGLE_BASEDIR, "RT_correction_hg38/1000G_RT_")
  PROBLEMLOCI = file.path(BEAGLE_BASEDIR, "probloci/probloci.txt.gz")
  CHROM_COORD_FILE=file.path(BEAGLE_BASEDIR,"chromosome_coordinates_hg38_chr.txt")
  BEAGLEREF.template = file.path(BEAGLE_BASEDIR, "beagle/chrCHROMNAME.1kg.phase3.v5a_GRCh38nounref.vcf.gz")
  BEAGLEPLINK.template = file.path(BEAGLE_BASEDIR, "beagle/plink.CHROMNAME.GRCh38.map")
  BEAGLEJAR = file.path(BEAGLE_BASEDIR,"beagle/beagle.08Feb22.fa4.jar")
  setwd(RUN_DIR)
  battenberg(analysis=analysis,
             tumourname=TUMOURNAME, 
             normalname=NORMALNAME, 
             tumour_data_file=TUMOURBAM, 
             normal_data_file=NORMALBAM, 
             ismale=ismaleinfo, 
             imputeinfofile=IMPUTEINFOFILE, 
             g1000prefix=G1000LOCIPREFIX, 
             g1000allelesprefix=G1000ALLELESPREFIX, 
             gccorrectprefix=GCCORRECTPREFIX, 
             repliccorrectprefix=REPLICCORRECTPREFIX, 
             problemloci=PROBLEMLOCI, 
             data_type="wgs",
             impute_exe=IMPUTE_EXE,
             allelecounter_exe=ALLELECOUNTER,
             usebeagle=TRUE,
             beaglejar=BEAGLEJAR,
             beagleref=BEAGLEREF.template,
             beagleplink=BEAGLEPLINK.template,
             beaglemaxmem=10,
             beaglenthreads=1,
             beaglewindow=40,
             beagleoverlap=4,
             javajre=JAVAJRE,
             nthreads=NTHREADS,
             platform_gamma=PLATFORM_GAMMA,
             phasing_gamma=PHASING_GAMMA,
             segmentation_gamma=SEGMENTATION_GAMMA,
             segmentation_kmin=SEGMENTATIIN_KMIN,
             phasing_kmin=PHASING_KMIN,
             clonality_dist_metric=CLONALITY_DIST_METRIC,
             ascat_dist_metric=ASCAT_DIST_METRIC,
             min_ploidy=MIN_PLOIDY,
             max_ploidy=MAX_PLOIDY,
             min_rho=MIN_RHO,
             min_goodness=MIN_GOODNESS_OF_FIT,
             uninformative_BAF_threshold=BALANCED_THRESHOLD,
             min_normal_depth=MIN_NORMAL_DEPTH,
             min_base_qual=MIN_BASE_QUAL,
             min_map_qual=MIN_MAP_QUAL,
             calc_seg_baf_option=CALC_SEG_BAF_OPTION,
             skip_allele_counting=FALSE,
             skip_preprocessing=FALSE,
             skip_phasing=FALSE,
             prior_breakpoints_file=NULL,
             GENOMEBUILD=GENOMEBUILD,
             chrom_coord_file=CHROM_COORD_FILE)
  }


