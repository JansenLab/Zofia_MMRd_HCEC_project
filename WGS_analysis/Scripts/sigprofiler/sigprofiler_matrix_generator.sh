#!/bin/bash
#$ -cwd
#$ -l tmem=12G
#$ -l h_vmem=12G
#$ -l h_rt=24:0:0
#$ -N matrix_generator
#$ -j y

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

source /share/apps/source_files/python/python-3.10.0.source
python3 <<EOF
from SigProfilerMatrixGenerator import install as genInstall
genInstall.install('GRCh38', rsync=True, bash=True)
from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen

matrices = matGen.SigProfilerMatrixGeneratorFunc("WGS_30x", "GRCh38", "/SAN/colcc/MMRd_HCEC_genomes/sigprofiler", plot=True)
EOF
