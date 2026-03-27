#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=10:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N WT_k36me3E_B_bam2bed
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_bam2bed.030125.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_bam2bed.030125.out

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

bedtools bamtobed -i "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/bam_unfiltered/CT_023_WT_k36me3E_B.bowtie2.mapped.bam" > "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/bed_unfiltered/CT_023_WT_k36me3E_B.bowtie2.bed"