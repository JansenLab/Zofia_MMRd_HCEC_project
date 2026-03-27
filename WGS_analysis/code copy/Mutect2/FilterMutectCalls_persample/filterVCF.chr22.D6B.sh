#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=120:0:0
#$ -R y
#$ -j y
#$ -N runFiltMutect_persample
#$ -e /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/filtMutect_D6B.22May2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/filtMutect_D6B.22May2024.out

/share/apps/jdk-17.0.1/bin/java -Xmx2g -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar FilterMutectCalls \
-R /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
-V /SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/persample/mutectCalls.chr22.D6B.vcf \
-O /SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/persample/mutectCalls.chr22.D6B.filtered.vcf


