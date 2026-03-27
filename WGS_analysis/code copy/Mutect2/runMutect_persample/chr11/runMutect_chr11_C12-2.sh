#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N runMutect_chr11_C12-2
#$ -e /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/mutect_chr11_C12-2.28May2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/mutect_chr11_C12-2.28May2024.out
  
/share/apps/jdk-17.0.1/bin/java -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar Mutect2 \
-R /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
-L chr11 \
NA
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/HC1/HC1.mkdub.bam \
-normal HC1 \
--germline-resource /SAN/colcc/sarc_amf/0.1.referenceFiles/af-only-gnomad.hg38.vcf.gz \
-O /SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/persample/mutectCalls.chr11_C12-2.vcf


