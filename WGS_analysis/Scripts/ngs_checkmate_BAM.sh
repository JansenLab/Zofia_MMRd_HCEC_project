#!/bin/sh
#$ -cwd
#$ -l tmem=12G
#$ -l h_vmem=12G
#$ -l h_rt=120:0:0 
#$ -pe smp 8
#$ -R y
#$ -j y 
#$ -N NGSCheckMate
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/NGSCheckMate_BAM.23Sep2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/NGSCheckMate_BAM.23Sep2024.out

source /share/apps/source_files/python/python-3.9.5.source
export PATH="/SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate/:$PATH"
export NCM_HOME=/SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate

python /SAN/colcc/MMRd_HCEC_genomes/NGSCheckMate/NGSCheckMate/ncm.py -B -l bam_list.txt -bed /SAN/colcc/pillaylab-software/NGSCheckMate/SNP/SNP_GRCh38_hg38_wChr.bed -O output_folder_2 -p 8
