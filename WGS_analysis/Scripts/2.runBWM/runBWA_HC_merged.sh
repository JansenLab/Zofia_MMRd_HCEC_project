#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N HC_merged_bwa 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/config/HC_merged.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/config/HC_merged.out  

echo reads in HC_merged fastq:
zcat /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_R1.fastq.gz | echo $((`wc -l`/4))

# align data 
bwa mem -M -t 12 -R '@RG\tID:HC2\tSM:HC2\tPL:ILLUMINA\tLB:HC2\tPU:lane1' /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_R1.fastq.gz /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_R2.fastq.gz | \
samtools view -q 1 -bS - >  /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.bam

# sort new bam file
samtools sort -o  /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.sorted.bam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I= /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.sorted.bam  MODE=SUMMARY


