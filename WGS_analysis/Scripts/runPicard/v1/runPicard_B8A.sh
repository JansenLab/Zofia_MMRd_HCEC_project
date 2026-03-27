#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N B8A_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/B8A.25Mar2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/B8A.25Mar2024.out
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.fixed.bam \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.fixed.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.mkdub.bam MODE=SUMMARY

rm /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.fixed.bam
