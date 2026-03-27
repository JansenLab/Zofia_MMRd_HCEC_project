#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N CT_027_F72_k36_A_bowtie 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/reports/CT_027_F72_k36_A.13Feb2025.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/reports/CT_027_F72_k36_A.13Feb2025.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh

echo reads in CT_027_F72_k36_A fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming/output/CT_027_F72_k36_A_EKDL240038902-1A_22L2W5LT4_1.trimmed.fq.gz  | echo $((`wc -l`/4))

echo reads in CT_027_F72_k36_A fastq:
echo $(( $(zcat /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming/output/CT_027_F72_k36_A_EKDL240038902-1A_22L2W5LT4_1.trimmed.fq.gz | wc -l) / 4 ))

bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 12 -x /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/bowtie2_human_ref_genome -1 /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming/output/CT_027_F72_k36_A_EKDL240038902-1A_22L2W5LT4_1.trimmed.fq.gz -2 /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/adapter_trimming/output/CT_027_F72_k36_A_EKDL240038902-1A_22L2W5LT4_2.trimmed.fq.gz -S /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output/CT_027_F72_k36_A.bowtie2.sam
