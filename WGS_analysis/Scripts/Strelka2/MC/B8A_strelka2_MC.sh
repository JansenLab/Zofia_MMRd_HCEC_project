#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N B8A_strelka2 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/B8A.2Sep2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/B8A.2Sep2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/B8A/ 

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/B8A.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/B8A/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/B8A/runWorkflow.py -m local -j 20
