#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=10:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N WT_k36me3E_B_min_mapq_filtering
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_min_mapq_filtering.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_min_mapq_filtering.out

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

samtools view -q 20 -h "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/rmDup_sam/CT_023_WT_k36me3E_B_bowtie2.sorted.rmDup.sam" > "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/rmDup_sam/CT_023_WT_k36me3E_B.bowtie2.qualityScore20.rmDup.sam"
