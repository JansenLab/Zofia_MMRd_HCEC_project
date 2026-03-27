#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=24:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N C7B_picard
#$ -e /SAN/colcc/MMRd_HCEC_genomes/picard/reports/coverage_metrics/C7B.9Apr2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/picard/reports/coverage_metrics/C7B.9Apr2024.out

module load R

mkdir /SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B

#get general sequence metrics
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectWgsMetrics \
I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C7B/C7B.mkdub.bam \
O=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B/C7B.seq_metrics.txt \
R=/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
COVERAGE_CAP=10000 \
MAX_RECORDS_IN_RAM=100000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B

#collect stats specific to interval size including a histogram
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectInsertSizeMetrics \
I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C7B/C7B.mkdub.bam \
O=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B/C7B.insert_metrics.txt \
H=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B/C7B.insert_hist.pdf \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B

#get general alignment stats such as % reads aligned
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar CollectAlignmentSummaryMetrics \
I=/SAN/colcc/MMRd_HCEC_genomes/bam_files/C7B/C7B.mkdub.bam \
O=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B/C7B.alignment_metrics.txt \
R=/SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=/SAN/colcc/MMRd_HCEC_genomes/coverage_files/C7B

