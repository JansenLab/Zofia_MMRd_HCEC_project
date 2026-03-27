#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=40:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N bed_binning
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_binning.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_binning.out

# Define project path
projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1"

# Path to the sample list file
sampleList="${projPath}/cuttag_batch1_sample_list.txt"

binLen=500

# Loop through each sample in the sample list
while read -r histName; do
  awk -v w=$binLen '{print $1, int(($2 + $3)/(2*w))*w + w/2}' $projPath/bowtie/output/bed/${histName}_bowtie2.fragments.bed | sort -k1,1V -k2,2n | uniq -c | awk -v OFS="\t" '{print $2, $3, $1}' |  sort -k1,1V -k2,2n  >$projPath/bowtie/output/bed/${histName}_bowtie2.fragmentsCount.bin$binLen.bed
done < "$sampleList"