# Nextflow

Nextflow
To run the script, do the trimming for raw reads, files of your choice. After trimming, save the files in the same dir as the script. To run this script: make a conda environemnt - in which skesa, checkm, mlst and nextflow are installed.

These are the codes:
conda create -n nextflow -c bioconda skesa checkm mlst nextflow

Use this code to run the script
nextflow run nextflow.nf trimmed_read1.fastq trimmed_read2.fastq
