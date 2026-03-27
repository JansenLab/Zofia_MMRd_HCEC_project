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

# sort new bam file
samtools sort -o  /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.sorted.bam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I= /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/HC_merged.sorted.bam  MODE=SUMMARY


