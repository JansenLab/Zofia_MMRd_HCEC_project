#$ -S /bin/bash
#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=300:0:0
#$ -R y
#$ -pe smp 8
#$ -wd /SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/work
#$ -N strelka2_on_merged_WT

echo 'Setup project'
projDir=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs
dataDir=/SAN/colcc/MMRd_HCEC_genomes/bcbio_wgs/final/bam_files
samplesheet=samplesheet_strelka_v2.csv

baseName=$(basename $samplesheet .csv)
echo baseName
 
# Export the path to bcbio
echo 'Setup bcbio path'
#installDir=/lustre/projects/pillay_genomics/Bcbio2/
installDir=/SAN/colcc/pillaylab-software/bcbio-pipeline/
export PATH=$installDir/tools/bin:$installDir/anaconda/bin:$PATH

# Create yaml config file for all samples from the sample sheet (.csv file) and the template.yaml file
echo 'Create yaml'
cd $projDir/config/
bcbio_nextgen.py -w template --only-metadata $projDir/config/config.yaml $projDir/config/$samplesheet $dataDir/*.bam
 
# set up java
echo 'Setup java path'
export BCBIO_JAVA_HOME=$installDir/anaconda/envs/java

# Move to the bcbio/work directory to run the bcbio pipeline
echo 'Run bcbio'
cd $projDir/work
bcbio_nextgen.py $projDir/config/$baseName/config/$baseName".yaml" -n 8

