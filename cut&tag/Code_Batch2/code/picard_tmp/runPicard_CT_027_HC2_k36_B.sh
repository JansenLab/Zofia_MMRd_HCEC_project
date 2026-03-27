#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=3:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N  CT_027_HC2_k36_B_picard 
#$ -o  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/reports_tmp/CT_027_HC2_k36_B.11Mar2025.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

mkdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/tmp/CT_027_HC2_k36_B_picard 
mkdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/ 
  
## Sort by coordinate
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar SortSam I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output_untrimmed/CT_027_HC2_k36_B.bowtie2.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B.bowtie2.sorted.sam SORT_ORDER=coordinate

## mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B.bowtie2.dupMarked.sam METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B_picard.dupMark.txt TMP_DIR= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/tmp/CT_027_HC2_k36_B_picard 
                        
## remove duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B_bowtie2.sorted.rmDup.sam REMOVE_DUPLICATES=true METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp/CT_027_HC2_k36_B/CT_027_HC2_k36_B_picard.rmDup.txt TMP_DIR= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/tmp/CT_027_HC2_k36_B_picard
