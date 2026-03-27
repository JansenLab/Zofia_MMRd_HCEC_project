#$ -S /bin/bash
#$ -l tmem=10G
#$ -l h_vmem=10G
#$ -l h_rt=3:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N  CT_027_HC1_IgG_A_picard 
#$ -o  /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/reports_tmp_scratch/CT_027_HC1_IgG_A.11Mar2025.out 

source /SAN/colcc/MMRd_HCEC_genomes/myCOLCCenv.sh 

mkdir -p scratch0/zpiszka/CT_027_HC1_IgG_A_picard 
mkdir /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/ 
  
## Sort by coordinate
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar SortSam I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/bowtie/output_untrimmed/CT_027_HC1_IgG_A.bowtie2.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A.bowtie2.sorted.sam SORT_ORDER=coordinate

## mark duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A.bowtie2.dupMarked.sam METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A_picard.dupMark.txt TMP_DIR= scratch0/zpiszka/CT_027_HC1_IgG_A_picard 
                        
## remove duplicates
java -jar /share/apps/genomics/picard-2.20.3/bin/picard.jar MarkDuplicates I= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A.bowtie2.sorted.sam O= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A_bowtie2.sorted.rmDup.sam REMOVE_DUPLICATES=true METRICS_FILE= /SAN/colcc/MMRd_HCEC_genomes/cuttag_batch2/picard/output_tmp_scratch/CT_027_HC1_IgG_A/CT_027_HC1_IgG_A_picard.rmDup.txt TMP_DIR= scratch0/zpiszka/CT_027_HC1_IgG_A_picard 

function finish {
     rm -rf  scratch0/zpiszka/CT_027_HC1_IgG_A_picard 
}
 
trap finish EXIT ERR INT TERM
