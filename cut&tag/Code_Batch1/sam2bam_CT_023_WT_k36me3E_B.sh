#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=10:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N WT_k36me3E_B_sam2bam
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_sam2bam.030125.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/WT_k36me3E_B_sam2bam.030125.out

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

samtools view -bS -F 0x04 "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/rmDup_sam/CT_023_WT_k36me3E_B_bowtie2.sorted.rmDup.sam" > "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/bam_unfiltered/CT_023_WT_k36me3E_B.bowtie2.mapped.bam"