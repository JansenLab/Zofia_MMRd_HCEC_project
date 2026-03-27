#!/bin/bash
#$ -cwd
#$ -l tmem=12G
#$ -l h_vmem=12G
#$ -l h_rt=48:0:0
#$ -N SP_extractor
#$ -j y

source /share/apps/source_files/python/python-3.10.0.source
source ./sigprofiler_env/bin/activate

python3 SP_extractor_SBS.py