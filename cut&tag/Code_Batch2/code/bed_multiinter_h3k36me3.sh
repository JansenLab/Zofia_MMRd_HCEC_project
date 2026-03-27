#!/bin/bash -l 

#$ -S /bin/bash
#$ -l h_rt=12:0:0
#$ -l mem=10G
#$ -l tmpfs=10G
#$ -pe smp 1
#$ -N bed_multiinter
#$ -wd /home/zcbtzkp/Scratch/cuttag_batch2_repth2/results/03_peak_calling/04_called_peaks/seacr

module load bedtools/2.25.0

bedtools multiinter -I h3k36me3_c121_R2.seacr.peaks.stringent.bed h3k36me3_hc1_R1.seacr.peaks.stringent.bed h3k36me3_f101_R1.seacr.peaks.stringent.bed h3k36me3_hc1_R2.seacr.peaks.stringent.bed h3k36me3_c11_R1.seacr.peaks.stringent.bed h3k36me3_f101_R2.seacr.peaks.stringent.bed h3k36me3_hc2_R1.seacr.peaks.stringent.bed h3k36me3_c11_R2.seacr.peaks.stringent.bed h3k36me3_f72_R1.seacr.peaks.stringent.bed h3k36me3_hc2_R2.seacr.peaks.stringent.bed h3k36me3_c121_R1.seacr.peaks.stringent.bed h3k36me3_f72_R2.seacr.peaks.stringent.bed > h3k36me3_multiinter.bed