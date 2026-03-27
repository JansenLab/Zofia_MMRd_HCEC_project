#!/bin/bash -l
#$ -l h_rt=48:00:00 #specify memory per core here
#$ -l mem=24G
#$ -wd /home/regmars/Scratch/CCS_batch6/Battenberg/
#$ -l tmpfs=100G
#$ -N CCSbatch6_battenberg
#$ -pe smp 6
echo 'Running CCS_battenberg'

module purge
module load r/recommended
export PATH="$PATH:/home/regmars/Scratch/softwares/packages/alleleCounter/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/regmars/Scratch/softwares/packages/alleleCounter/lib"
Rscript battenberg_batch6.R

