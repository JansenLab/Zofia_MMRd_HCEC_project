#$ -S /bin/bash
#$ -l tmem=32G
#$ -l h_vmem=100G
#$ -l h_rt=120:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N B8B_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/B8B.26Mar2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/B8B.26Mar2024.out
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.fixed.bam \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.fixed.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.mkdub.bam MODE=SUMMARY

rm /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.fixed.bam
