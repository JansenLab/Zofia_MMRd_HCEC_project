#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N F7-1_bwa 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/F7-1.9Apr2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/F7-1.9Apr2024.out 

mkdir  /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1     

echo reads in F7 -1 fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/fastq_files/F7-1_1.fastq.gz  | echo $((`wc -l`/4))

# align data 
bwa mem -M -t 12 -R '@RG\tID:F7-1\tSM:F7-1\tPL:ILLUMINA\tLB:F7-1\tPU:lane1' /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa /SAN/colcc/MMRd_HCEC_genomes/fastq_files/F7-1_1.fastq.gz /SAN/colcc/MMRd_HCEC_genomes/fastq_files/F7-1_2.fastq.gz | \
samtools view -q 1 -bS - >  /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1.bam 

# sort new bam file
samtools sort -o  /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1.sorted.bam /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1.bam 

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I= /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1.sorted.bam  MODE=SUMMARY


