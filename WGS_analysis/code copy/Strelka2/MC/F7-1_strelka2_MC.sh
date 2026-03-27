#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N F7-1_strelka2 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/F7-1.2Sep2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/F7-1.2Sep2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/F7-1/ 

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/F7-1.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/F7-1/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/F7-1/runWorkflow.py -m local -j 20
