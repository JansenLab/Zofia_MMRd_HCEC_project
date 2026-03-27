#!/bin/sh
#$ -cwd
#$ -V
#$ -l tmem=4G
#$ -l h_vmem=4G
#$ -l h_rt=5:0:0      

export PATH=/share/apps/python-3.9.5-shared/bin/:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.9.5-shared/lib/:$LD_LIBRARY_PATH

multiqc .