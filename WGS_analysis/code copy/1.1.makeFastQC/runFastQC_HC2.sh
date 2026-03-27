#!/bin/sh
#$ -cwd
#$ -V
#$ -l tmem=4G
#$ -l h_vmem=4G
#$ -l h_rt=5:0:0      # Request 5 hour runtime

export PATH="/share/apps/jdk1.8.0_131/bin/:\$PATH"

/share/apps/genomics/FastQC-0.11.9/fastqc --outdir /SAN/colcc/MMRd_HCEC_genomes/fastqc/reports /SAN/colcc/MMRd_HCEC_genomes/fastq_files/HC2_1.fastq.gz /SAN/colcc/MMRd_HCEC_genomes/fastq_files/HC2_2.fastq.gz
