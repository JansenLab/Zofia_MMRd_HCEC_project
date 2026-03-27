#!/bin/bash
#$ -cwd
#$ -l tmem=1000G
#$ -l h_vmem=1000G
#$ -l h_rt=72:0:0
#$ -N topography_MACS_WT
#$ -R y
#$ -j y

source /share/apps/source_files/python/python-3.10.0.source
source /SAN/colcc/MMRd_HCEC_genomes/sigprofiler/sigprofiler_env/bin/activate

python3 /SAN/colcc/MMRd_HCEC_genomes/sigprofiler/topography_boyu/code/python/topography_my_macs_file_WT.v2.py.txt