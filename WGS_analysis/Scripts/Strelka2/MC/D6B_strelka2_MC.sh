#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N D6B_strelka2 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/D6B.2Sep2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/strelka2/reports_MC/D6B.2Sep2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/D6B/ 

/SAN/colcc/MMRd_CRC/WGS/output/strelka/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/D6B.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/D6B/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/strelka2/output_MC/D6B/runWorkflow.py -m local -j 20
