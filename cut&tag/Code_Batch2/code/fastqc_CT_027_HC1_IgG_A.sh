#!/bin/bash
#$ -cwd
#$ -V
#$ -l tmem=8G
#$ -l h_vmem=8G
#$ -l h_rt=12:0:0

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

fastqc --outdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/fastqc/output /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/raw_data/X204SC24121583-Z01-F001/01.RawData/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A_EKDL240038894-1A_22K7G5LT4_L3_1.fq.gz /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/raw_data/X204SC24121583-Z01-F001/01.RawData/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A_EKDL240038894-1A_22K7G5LT4_L3_2.fq.gz