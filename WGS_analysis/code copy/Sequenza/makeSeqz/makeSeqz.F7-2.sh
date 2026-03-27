#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=80:0:0
#$ -pe smp 4
#$ -R y
#$ -j y
#$ -N F7-2_makeSeqz
#$ -e /SAN/colcc/MMRd_HCEC_genomes/sequenza/reports/F7-2.15Oct2024.err
#$ -o /SAN/colcc/MMRd_HCEC_genomes/sequenza/reports/F7-2.15Oct2024.out

export PATH=/share/apps/python-3.9.5-shared/bin/:$PATH
export LD_LIBRARY_PATH=/share/apps/python-3.9.5-shared/lib/:$LD_LIBRARY_PATH

#make analysis dir
mkdir /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/

#get .seqz file
sequenza-utils bam2seqz -gc /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.gc50base.txt --fasta /SAN/colcc/sarc_amf/0.1.referenceFiles/GRCh38_full_analysis_set_plus_decoy_hla.fa -n /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/HCEC-MC.mkdub.bam -t /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files/F7-2.mkdub.bam -o /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/F7-2.seqz.gz

#bin .seqz file to shorten analysis time
sequenza-utils seqz_binning -w 250 -s /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/F7-2.seqz.gz -o /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/F7-2.seqz.binned.gz --tabix tabix-0.2.6/

chmod 777 /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/F7-2.seqz.gz
chmod 777 /SAN/colcc/MMRd_HCEC_genomes/sequenza/output/F7-2/F7-2.seqz.binned.gz

#run pre-processed files using sequenza in R locally
