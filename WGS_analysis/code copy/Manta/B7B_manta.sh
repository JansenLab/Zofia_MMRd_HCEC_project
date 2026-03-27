#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=1000:0:0
#$ -R y
#$ -j y
#$ -N B7B_manta 
#$ -e /SAN/colcc/MMRd_HCEC_genomes/manta/reports/B7B.26Sep2024.err 
#$ -o /SAN/colcc/MMRd_HCEC_genomes/manta/reports/B7B.26Sep2024.out 

mkdir /SAN/colcc/MMRd_HCEC_genomes/manta/output/B7B/ 

/share/apps/genomics/manta-1.6.0/bin/configManta.py \
  --normalBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/MLH1-A6-PC.mkdub.bam \
  --tumorBam /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/B7B.mkdub.bam \
  --referenceFasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --runDir /SAN/colcc/MMRd_HCEC_genomes/manta/output/B7B/ 
                   
# execution on a single local machine with 20 parallel jobs
 /SAN/colcc/MMRd_HCEC_genomes/manta/output/B7B/runWorkflow.py -m local -j 20
