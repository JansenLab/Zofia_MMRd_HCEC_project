#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=40:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N bed_filtering
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_filtering.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bed_filtering.out

# Define project path
projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1"

# Path to the sample list file
sampleList="${projPath}/sample_list_for_bed_filtering.txt"

# Loop through each sample file listed in sample_list.txt
while read sample_file; do
    # Check if the file exists
    if [[ -f "$sample_file" ]]; then
        echo "Processing $sample_file..."
        
        # Define output file name by appending "_filtered" to the original filename
        output_file="${sample_file%.bed}_filtered.bed"
        
        # Process the file with AWK
        awk '
            NR % 2 == 1 {  # Process every first line of the pair
                chr1 = $1; start1 = $2; end1 = $3; id1 = $4; score1 = $5; strand1 = $6;
                getline;   # Move to the next line (second read)
                chr2 = $1; start2 = $2; end2 = $3; id2 = $4; score2 = $5; strand2 = $6;
                
                # Check if they are on the same chromosome
                if (chr1 == chr2) {
                    # Calculate fragment size: from start1 to end2
                    fragment_size = (end2 > start1) ? (end2 - start1) : (start1 - end2);
                    
                    # Filter pairs with fragment size less than 1000
                    if (fragment_size < 1000) {
                        print chr1, start1, end1, id1, score1, strand1;
                        print chr2, start2, end2, id2, score2, strand2;
                    }
                }
            }
        ' OFS="\t" "$sample_file" > "$output_file"
        
        echo "Filtered results saved to $output_file"
    else
        echo "File $sample_file not found!"
    fi
done < sample_list.txt