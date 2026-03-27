#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=120:0:0
#$ -pe smp 12
#$ -R y
#$ -j y
#$ -N runMutect_chr2
#$ -e /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/mutect_chr2.8May2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/mutect2/reports/mutect_chr2.8May2024.out
  
/share/apps/jdk-17.0.1/bin/java -jar /share/apps/genomics/gatk-4.4.0.0/gatk-package-4.4.0.0-local.jar Mutect2 \
-R /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa \
-L chr2 \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/HC2/HC2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A2-1/A2-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A2-2/A2-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A6-1/A6-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A6-2/A6-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-1/C1-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C1-2/C1-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C12-1/C12-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C12-2/C12-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-1/F7-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/F7-2/F7-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/F10-1/F10-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/F10-2/F10-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-1/H2-1.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/H2-2/H2-2.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A5A/A5A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A5B/A5B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A6A/A6A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/A6B/A6B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/B7A/B7A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/B7B/B7B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8A/B8A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/B8B/B8B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C7A/C7A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C7B/C7B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C8A/C8A.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/C8B/C8B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/D6B/D6B.mkdub.bam \
-I /SAN/colcc/MMRd_HCEC_genomes/bam_files/HC1/HC1.mkdub.bam \
-normal HC1 \
--germline-resource /SAN/colcc/sarc_amf/0.1.referenceFiles/af-only-gnomad.hg38.vcf.gz \
-O /SAN/colcc/MMRd_HCEC_genomes/mutect2/vcf_files/mutectCalls.chr2.vcf


