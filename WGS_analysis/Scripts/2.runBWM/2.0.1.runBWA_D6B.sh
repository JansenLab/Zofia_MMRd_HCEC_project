#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N D6B_bwa 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/D6B.9Apr2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/D6B.9Apr2024.out 

mkdir  /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B     

echo reads in D6 B fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/fastq_files/D6B_1.fastq.gz  | echo $((`wc -l`/4))

# align data 
bwa mem -M -t 12 -R '@RG\tID:D6B\tSM:D6B\tPL:ILLUMINA\tLB:D6B\tPU:lane1' /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa /SAN/colcc/MMRd_HCEC_genomes/fastq_files/D6B_1.fastq.gz /SAN/colcc/MMRd_HCEC_genomes/fastq_files/D6B_2.fastq.gz | \
samtools view -q 1 -bS - >  /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B.bam 

# sort new bam file
samtools sort -o  /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B.sorted.bam /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B.bam 

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I= /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B.sorted.bam  MODE=SUMMARY


