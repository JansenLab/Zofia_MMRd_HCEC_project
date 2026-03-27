#!/bin/bash -l
#$ -S /bin/bash
#$ -l h_rt=150:0:0
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -pe smp 4
#$ -N sequenzaR.3.5.sh
#$ -o /SAN/colcc/MMRd_HCEC_genomes/sequenza/reports/sequenzaR.16Oct2024.olog
#$ -e /SAN/colcc/MMRd_HCEC_genomes/sequenza/reports/sequenzaR.16Oct2024.elog

export PATH=/share/apps/R-3.5.2/bin:$PATH

R CMD BATCH  /SAN/colcc/MMRd_CRC/sequenza/code/sequenzaR_v2.R
