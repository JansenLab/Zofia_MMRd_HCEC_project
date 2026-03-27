#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=3:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N  CT_027_HC1_k36_B_picard 
#$ -e  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/reports_filtered/CT_027_HC1_k36_B.10Mar2025.err 
#$ -o  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/reports_filtered/CT_027_HC1_k36_B.10Mar2025.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

mkdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/ 
  
## Sort by coordinate
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar SortSam I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/filter_empty_reads_output/CT_027_HC1_k36_B.bowtie2.filt.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B.bowtie2.sorted.sam SORT_ORDER=coordinate

## mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B.bowtie2.dupMarked.sam METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B_picard.dupMark.txt  
                        
## remove duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B_bowtie2.sorted.rmDup.sam REMOVE_DUPLICATES=true METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_filtered/CT_027_HC1_k36_B/CT_027_HC1_k36_B_picard.rmDup.txt
