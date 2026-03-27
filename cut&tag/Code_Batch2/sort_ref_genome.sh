#!/bin/bash -l 

#$ -S /bin/bash
#$ -l h_rt=2:0:0
#$ -l mem=10G
#$ -l tmpfs=10G
#$ -pe smp 1
#$ -N ref_genome_by_chr

module load /shared/ucl/apps/samtools/1.9/gnu-4.9.2/bin

for chr in $(cut -f1 genome.fa.fai); do
    samtools faidx genome.fa $chr > ${chr}.fa
done
