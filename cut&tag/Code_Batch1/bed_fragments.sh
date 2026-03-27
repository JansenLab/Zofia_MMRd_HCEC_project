#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=40:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N bed_fragments
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_fragments.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_fragments.out

# Define project path
projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1"

# Path to the sample list file
sampleList="${projPath}/sample_list_for_bed_fragments.txt"

# Loop through each sample file listed in the sample list
while read sampleFile; do
    echo "Processing $sampleFile..."
    
    # Run the cut and sort commands on each sample file
    cut -f 1,2,3 "$projPath/bowtie/output/bed/${sampleFile}.clean.bed" | \
    sort -k1,1 -k2,2n -k3,3n > "$projPath/bowtie/output/bed/${sampleFile}.fragments.bed"

    echo "Output written to ${sampleFile}.fragments.bed"
done < "$sample_list"
        
       
  