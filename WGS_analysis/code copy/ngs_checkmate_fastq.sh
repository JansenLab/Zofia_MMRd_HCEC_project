#!/bin/sh
#$ -cwd
#$ -l tmem=12G
#$ -l h_vmem=12G
#$ -l h_rt=80:0:0
#$ -pe smp 8
#$ -R y
#$ -j y 
#$ -N NGSCheckMate
#$ -e /SAN/colcc/MMRd_HCEC_genomes/fastq_files/NGSCheckMate.23Sep2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/fastq_files/NGSCheckMate.23Sep2024.out

source /share/apps/source_files/python/python-3.9.5.source
export PATH="/SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate/:$PATH"
export NCM_HOME=/SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate

python /SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate/ncm_fastq.py -l fastq_list.txt -O output_folder_2 -N NGS_ChM -pt /SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate/SNP/SNP.pt -p 8
