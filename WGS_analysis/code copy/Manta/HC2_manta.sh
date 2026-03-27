#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N HC2_manta 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/manta/reports/HC2.26Sep2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/manta/reports/HC2.26Sep2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/manta/output/HC2/ 

/share/apps/genomics/manta-1.6.0/bin/configManta.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HC2.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/manta/output/HC2/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/manta/output/HC2/runWorkflow.py -m local -j 20
