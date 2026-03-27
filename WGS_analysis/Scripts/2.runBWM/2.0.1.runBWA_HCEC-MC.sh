#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N HCEC-MC_bwa 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/HCEC-MC.20Aug2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/HCEC-MC.20Aug2024.out 

echo reads in HCEC-MC fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/fastq_files/HCEC-MC_R1.fastq.gz  | echo $((`wc -l`/4))

# align data 
bwa mem -M -t 12 -R '@RG\tID:HCEC-MC\tSM:HCEC-MC\tPL:ILLUMINA\tLB:HCEC-MC\tPU:lane1' /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa /SAN/colcc/MMRd_HCEC_genomes/fastq_files/HCEC-MC_R1.fastq.gz /SAN/colcc/MMRd_HCEC_genomes/fastq_files/HCEC-MC_R2.fastq.gz | \
samtools view -q 1 -bS - >  /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.bam 

# sort new bam file
samtools sort -o  /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.sorted.bam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.bam 

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I= /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.sorted.bam  MODE=SUMMARY


