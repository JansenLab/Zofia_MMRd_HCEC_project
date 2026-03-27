#!/bin/bash -l 

#$ -S /bin/bash
#$ -l h_rt=48:0:0
#$ -l mem=10G
#$ -l tmpfs=10G
#$ -pe smp 1
#$ -N cutandrun
#$ -wd /home/zcbtzkp/Scratch/cuttag_batch2

shopt -s expand_aliases

module load blic-modules
module load nfcore/cutandrun/3.2.2

nfcore_cutandrun \
	--input ./samplesheet_test.csv \
	--outdir ./results \
	--genome GRCh38 \
	--save_merged_fastq \
	--save_trimmed \
	--normalisation_mode=BPM \
	--peakcaller SEACR,MACS2 \
	--igg_scale factor=1 \
	-resume