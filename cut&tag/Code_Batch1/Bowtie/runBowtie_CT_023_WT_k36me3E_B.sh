#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N CT_023_WT_k36me3E_B_bowtie 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/CT_023_WT_k36me3E_B.24Oct2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/CT_023_WT_k36me3E_B.24Oct2024.out 

echo reads in CT_023_WT_k36me3E_B fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1_from_Claudia/zofia_cuttag/fastp/CT_023_WT_k36me3E_B_1.trimmed.fastq.gz  | echo $((`wc -l`/4))

bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 12 -x /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/bowtie2_human_ref_genome -1 /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1_from_Claudia/zofia_cuttag/fastp/CT_023_WT_k36me3E_B_1.trimmed.fastq.gz -2 /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1_from_Claudia/zofia_cuttag/fastp/CT_023_WT_k36me3E_B_2.trimmed.fastq.gz -S /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/CT_023_WT_k36me3E_B.bowtie2.sam
