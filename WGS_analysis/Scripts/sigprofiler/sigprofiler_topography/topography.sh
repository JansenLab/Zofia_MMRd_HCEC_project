#!/bin/bash
#$ -cwd
#$ -l tmem=24G
#$ -l h_vmem=24G
#$ -l h_rt=72:0:0
#$ -pe smp 12
#$ -N topography_prob_mode_explicit_plotting
#$ -R y
#$ -j y

source /share/apps/source_files/python/python-3.10.0.source
source /SAN/colcc/MMRd_HCEC_genomes/sigprofiler/sigprofiler_env/bin/activate

python3 topography_prob_mode_explicit_plotting.py
