#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=40:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N min_mapq_filtering
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/min_mapq_filtering.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/min_mapq_filtering.out

minQualityScore=20

while read -r sampleName; do
	samtools view -q $minQualityScore "$/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/${histName}_bowtie2.sam" >"$/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/${histName}_bowtie2.qualityScore$minQualityScore.sam"
done < "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/cuttag_batch1_sample_list.txt"