#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N bowtie_untrimmed 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/bowtie_untrimmed.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

projPath="/SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/raw_data/X204SC24121583-Z01-F001/01.RawData"
sampleList="${projPath}/fastq_list.txt"
simpleSampleList="${projPath}/simple_fastq_list.txt"

paste "$sampleList" "$simpleSampleList" | while read -r sample simpleSample; do
  # Define input and output file paths
  input_fileF="${projPath}/${sample}_1.fq.gz"
  input_fileR="${projPath}/${sample}_2.fq.gz"
  output_file="${simpleSample}.bowtie2.sam"

  # Run bowtie
  bowtie2 --local --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p 12 -x /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/bowtie2_human_ref_genome -1 "${input_fileF}" -2 "${input_fileR}" -S "${output_file}"
done