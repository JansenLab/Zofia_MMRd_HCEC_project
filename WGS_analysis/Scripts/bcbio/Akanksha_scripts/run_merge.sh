#$ -l tmem=20G
#$ -l h_vmem=20G
#$ -l h_rt=30:0:0
#$ -S /bin/bash
#$ -R y
#$ -pe smp 8
#$ -wd projectfolder#foryou
#$ -N merge_HC


# sort out cores
echo 'Setup cores'
export OMP_NUM_THREADS=8

echo 'Setup project'
projDir=bcbiofolder#foryou
dataDir=RawDatafolder#foryou

# Export the path to bcbio
echo 'Setup bcbio path'
installDir=/SAN/colcc/pillaylab-software/bcbio-pipeline/
export PATH=$installDir/tools/bin:$installDir/anaconda/bin:$PATH
samplesheet=batch_merge.csv # if running new batches, change this to the new samplesheet name - out folder will be created with this name e.g. filelist_batches for this example

baseName=$(basename $samplesheet .csv)
echo baseName
 
# set up java
echo 'Setup java path'
export BCBIO_JAVA_HOME=$installDir/anaconda/envs/java

#echo 'Merge multiple fastq files of one sample'
cd $projDir/config/
bcbio_prepare_samples.py --out path/to/merged/folder#foryou --csv batch_merge.csv

