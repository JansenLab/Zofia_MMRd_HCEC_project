#$ -S /bin/bash
#$ -l tmem=15G
#$ -l h_vmem=15G
#$ -l h_rt=120:0:0
#$ -pe smp 1
#$ -R y
#$ -j y
#$ -N J970002_seqz
#$ -e /SAN/colcc/MMRd_CRC/reports/sequenza/J970002.20Apr2023.err
#$ -o /SAN/colcc/MMRd_CRC/reports/sequenza/J970002.20Apr2023.out

export PATH=/share/apps/python-3.9.5-shared/bin:$PATH
module load python

#make analysis dir
mkdir /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002

#get .seqz file
sequenza-utils bam2seqz -gc /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.gc50base.txt --fasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa -n /SAN/colcc/MMRd_CRC/bamFiles/J970001/J970001.mkdub.bam -t /SAN/colcc/MMRd_CRC/bamFiles/J970002/J970002.mkdub.bam -o /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002.seqz.gz

#bin .seqz file to shorten analysis time
sequenza-utils seqz_binning -w 250 -s /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002.seqz.gz -o /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002.seqz.binned.gz --tabix tabix-0.2.6/

chmod 777 /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002.seqz.gz
chmod 777 /SAN/colcc/MMRd_CRC/bamFiles/Sequenza/J970002.seqz.binned.gz

#run pre-processed files using sequenza in R locally

