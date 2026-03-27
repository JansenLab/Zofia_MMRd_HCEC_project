#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=40:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N min_mapq_filtering
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_conversion.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_conversion.out

# Define project path
projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1"

# Path to the sample list file
sampleList="${projPath}/cuttag_batch1_sample_list.txt"

# Loop through each sample in the sample list
while read -r histName; do
  echo "Processing sample: $histName"

  ## Filter and keep the mapped read pairs
  samtools view -bS -F 0x04 \
    "$projPath/bowtie/output/sam/${histName}_bowtie2.qualityScore20.sam" \
    > "$projPath/bowtie/output/bam/${histName}_bowtie2.mapped.bam"

  ## Convert into bed file format
  bedtools bamtobed \
    -i "$projPath/bowtie/output/bam/${histName}_bowtie2.mapped.bam" \
    > "$projPath/bowtie/output/bed/${histName}_bowtie2.bed"

  ## Keep the read pairs that are on the same chromosome and fragment length less than 1000bp
  awk '$1==$4 && $6-$2 < 1000 {print $0}' \
    "$projPath/bowtie/output/bed/${histName}_bowtie2.bed" \
    > "$projPath/bowtie/output/bed/${histName}_bowtie2.clean.bed"

  ## Only extract the fragment related columns
  cut -f 1,2,6 "$projPath/bowtie/output/bed/${histName}_bowtie2.clean.bed" | \
    sort -k1,1 -k2,2n -k3,3n \
    > "$projPath/bowtie/output/bed/${histName}_bowtie2.fragments.bed"

  echo "Completed processing for sample: $histName"
done < "$sampleList"