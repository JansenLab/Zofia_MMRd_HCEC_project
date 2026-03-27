#!/bin/bash
#$ -l tmem=24G
#$ -l h_vmem=24G
#$ -l h_rt=48:0:0
#$ -pe smp 6
#$ -wd /SAN/colcc/MMRd_HCEC_genomes/battenberg/
#$ -R y
#$ -N Battenberg
#$ -e /SAN/colcc/MMRd_HCEC_genomes/battenberg/reports/battenberg.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/battenberg/reports/battenberg.out
 
echo 'Running CCS_battenberg'

module purge
export PATH=/share/apps/R-4.4.1/bin/:$PATH
export LD_LIBRARY_PATH=/share/apps/R-4.4.1/lib64/:$LD_LIBRARY_PATH
export PATH=/share/apps/genomics/alleleCount-4.2.1/bin/:$PATH
export LD_LIBRARY_PATH=/share/apps/genomics/alleleCount-4.2.1/lib/:$LD_LIBRARY_PATH

Rscript battenberg.R

