Below is a Nextflow script for trimming and assembling paired-end FASTQ filesusing Fastp for trimming and SPAdes for assembly
#Created conda env

conda env create ex3

#exracted fastq files from NCBI - SRR27871203

Here's the command I used to Download them.
fasterq-dump
SRR26669254 --threads 1
--outdir ~/exercise_3/raw_data
--split-files
--skip-technical

To compressed, the command used is:
pigz -9f *.fastq

Compressed the files - SRR27871203_1.fastq , SRR27871203_2.fastq

Run the Nextflow script:
./nextflow run workflow.nf

As my previous files were large and wasn't able to upload. Hence, I have redownloaded and uploaded the smaller size files.


# Nextflow

Nextflow
To run the script, do the trimming for raw reads, files of your choice. After trimming, save the files in the same dir as the script. To run this script: make a conda environemnt - in which skesa, checkm, mlst and nextflow are installed.

These are the codes:
conda create -n nextflow -c bioconda skesa checkm mlst nextflow

Use this code to run the script
nextflow run nextflow.nf trimmed_read1.fastq trimmed_read2.fastq
