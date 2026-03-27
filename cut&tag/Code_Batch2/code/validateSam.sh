#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=12:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N validateSam
#$ -o /SAN/colcc/MMRd_HCEC_genomes/bwa_mem/reports/A2-1.9Apr2024.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

for file in /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output/*.bowtie2.sam; do
    java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar ValidateSamFile \
        I="$file" \
        MODE=SUMMARY \
        O="${file%.sam}.validation_report.txt"
done