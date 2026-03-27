# Loop through each sample in the file
while read -r sampleName; do
  # Run the samtools command for each sample
  samtools view -F 0x04 "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/${sampleName}_bowtie2.sam" \
    | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' \
    | sort | uniq -c \
    | awk -v OFS="\t" '{print $2, $1/2}' \
    > "/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/output/fragmentLen/${sampleName}_fragmentLen.txt"
done < /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/cuttag_batch1_sample_list.txt