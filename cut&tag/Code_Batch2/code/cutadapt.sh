#!/bin/bash
#$ -wd /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming
#$ -V
#$ -l tmem=8G
#$ -l h_vmem=8G
#$ -l h_rt=12:0:0

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/raw_data/X204SC24121583-Z01-F001/01.RawData"
sampleList="${projPath}/fastq_list.txt"

while read -r sample; do
  # Define input and output file paths
  input_file="${projPath}/${sample}.fq.gz"
  output_file="${sample}_trimmed.fq.gz"

  # Run cutadapt
  cutadapt -a CTGTCTCTTATA -o "$output_file" "$input_file"
done < "$sampleList"