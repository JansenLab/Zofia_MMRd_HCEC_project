#!/bin/bash

# Define the base directory where all samples are located
BASE_DIR="/SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC"

# Define the output directory for processed files
OUTPUT_DIR="/SAN/colcc/MMRd_HCEC_genomes/strelka2/processed_vcfs"

# Create the output directory if it does not exist
mkdir -p "${OUTPUT_DIR}"

# Loop through each sample directory
for sample_dir in "${BASE_DIR}"/*/results/variants; do
    # Extract the sample name from the directory path
    sample_name=$(basename "$(dirname "$(dirname "${sample_dir}")")")

    # Process both somatic.snvs.vcf.gz and somatic.indels.vcf.gz files
    for file_type in somatic.snvs.vcf.gz somatic.indels.vcf.gz; do
        # Input file path
        input_file="${sample_dir}/${file_type}"
        
        # Check if input file exists
        if [[ -f "${input_file}" ]]; then
            # Define the temporary and output file names
            temp_file="${OUTPUT_DIR}/${sample_name}_${file_type%.vcf.gz}.temp.vcf.gz"
            output_file="${OUTPUT_DIR}/${sample_name}_${file_type%.vcf.gz}.pass.vcf.gz"

            # Print the input and output file information
            echo "Processing ${input_file}..."

            # Run bcftools commands
            bcftools view "${input_file}" --regions chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY -O z -o "${temp_file}"
            bcftools view -f PASS "${temp_file}" -O z -o "${output_file}"

            # Remove the temporary file
            rm "${temp_file}"

            echo "Output written to ${output_file}"
        else
            echo "Warning: ${input_file} does not exist. Skipping..."
        fi
    done
done
