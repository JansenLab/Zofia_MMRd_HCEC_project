#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N A5B_strelka2 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports/A5B.10Jul2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports/A5B.10Jul2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output/A5B/ 

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HC_merged.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/A5B.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output/A5B/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/strelka2/output/A5B/runWorkflow.py -m local -j 20
