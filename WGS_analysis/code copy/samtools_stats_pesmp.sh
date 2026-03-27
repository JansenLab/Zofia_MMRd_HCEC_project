#!/bin/sh
#$ -cwd
#$ -V
#$ -l h_rt=150:0:0
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -pe smp 4
#$ -N samtools_stats
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/samtools_stats.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/samtools_stats.out 
      

samtools stats HCEC-MC.bam > HCEC-MC_stats.txt
samtools stats A6-2.bam > A6-2_stats.txt
samtools stats C1-2.bam > C1-2_stats.txt
samtools stats F7-1.bam > F71_stats.txt
samtools stats B8B.bam > B8B_stats.txt
