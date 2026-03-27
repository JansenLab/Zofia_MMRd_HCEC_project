#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=3:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N  CT_023_WT_k36me3A_B_picard 
#$ -e  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/reports/CT_023_WT_k36me3A_B.31Oct2024.err 
#$ -o  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/reports/CT_023_WT_k36me3A_B.31Oct2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/ 
  
## Sort by coordinate
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar SortSam I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/CT_023_WT_k36me3A_B.bowtie2.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B.bowtie2.sorted.sam SORT_ORDER=coordinate

## mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B.bowtie2.dupMarked.sam METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B_picard.dupMark.txt  
                        
## remove duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B_bowtie2.sorted.rmDup.sam REMOVE_DUPLICATES=true METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/picard/output/CT_023_WT_k36me3A_B/CT_023_WT_k36me3A_B_picard.rmDup.txt
