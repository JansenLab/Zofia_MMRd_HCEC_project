#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N bowtie2_ref_genome_indexing
#$ -e /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bowtie2_indexing.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/reports/bowtie2_indexing.out

bowtie2-build /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch1/bowtie/bowtie2_human_ref_genome