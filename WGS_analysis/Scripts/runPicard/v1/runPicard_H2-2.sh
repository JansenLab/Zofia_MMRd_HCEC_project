#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N H2-2_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/H2-2.25Mar2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/H2-2.25Mar2024.out
  
#fix broken paired end reads; unhash if needed
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar FixMateInformation \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.fixed.bam \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.fixed.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.mkdub.bam MODE=SUMMARY

rm /SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.fixed.bam
