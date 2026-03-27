#$ -S /bin/bash
#$ -l tmem=32G
#$ -l h_vmem=100G
#$ -l h_rt=120:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N C1-1_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/C1-1.26Mar2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/C1-1.26Mar2024.out
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.fixed.bam \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.fixed.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.mkdub.bam MODE=SUMMARY

rm /SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.fixed.bam
