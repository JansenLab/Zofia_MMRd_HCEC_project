#!/bin/bash
#$ -cwd
#$ -V
#$ -l tmem=8G
#$ -l h_vmem=8G
#$ -l h_rt=12:0:0

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/raw_data/X204SC24121583-Z01-F001/01.RawData"

sampleList="${projPath}/fastq_list.csv"

while read -r sample; do
  fastqc --outdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/fastqc/output $projPath/${sample}_1.fq.gz ${projPath}/${sample}_2.fq.gz
done < "$sampleList"