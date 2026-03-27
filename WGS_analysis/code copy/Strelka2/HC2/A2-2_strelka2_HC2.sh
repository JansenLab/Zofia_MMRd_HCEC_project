#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N A2-2_strelka2 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_HC2/A2-2.16Aug2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_HC2/A2-2.16Aug2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_HC2/A2-2/ 

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HC2.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/A2-2.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_HC2/A2-2/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_HC2/A2-2/runWorkflow.py -m local -j 20
