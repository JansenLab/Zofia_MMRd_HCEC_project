#$ -S /bin/bash
#$ -l tmem=12G
#$ -l h_vmem=12G
#$ -l h_rt=50:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N filter_empty_reads
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/reports/filter_empty_reads.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

# Create output directory if it doesn't exist
mkdir -p /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/filter_empty_reads_output

for file in /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output/*.bowtie2.sam; do
    awk 'length($10) > 0 && $10 != "*"' "$file" > /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/filter_empty_reads_output/$(basename "$file" .sam).filt.bowtie2.sam
done