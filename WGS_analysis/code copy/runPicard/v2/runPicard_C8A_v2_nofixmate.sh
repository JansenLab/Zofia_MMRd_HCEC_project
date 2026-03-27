#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=24:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N C8A_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/C8A.19Apr2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/C8A.19Apr2024.out

#mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates \
INPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.sorted.bam \
OUTPUT=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.nofixmate.mkdub.bam \
METRICS_FILE=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.nofixmate.mkdub.metrics.txt \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=100000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A
                        
#build index file
samtools index /SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.nofixmate.mkdub.bam

# validate final alignment
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.nofixmate.mkdub.bam MODE=SUMMARY

