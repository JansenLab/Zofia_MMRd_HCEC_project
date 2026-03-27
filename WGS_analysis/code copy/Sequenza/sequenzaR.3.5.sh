#!/bin/bash -l
#$ -S /bin/bash
#$ -l h_rt=300:0:0
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -pe smp 2
#$ -N sequenzaR.3.5.sh
#$ -o /SAN/colcc/MMRd_CRC/sequenza/sequenza.3.5.18Jan2023.olog
#$ -e /SAN/colcc/MMRd_CRC/sequenza/sequenza.3.5.18Jan2023.elog

export PATH=/share/apps/R-3.5.2/bin:$PATH

R CMD BATCH  /SAN/colcc/MMRd_CRC/sequenza/scripts/sequenzaR.3.5.R

