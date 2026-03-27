#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N MLH1-A6-PC_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/MLH1-A6-PC.22Aug2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/MLH1-A6-PC.22Aug2024.out
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.fixed.bam \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.fixed.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam MODE=SUMMARY

rm /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.fixed.bam
