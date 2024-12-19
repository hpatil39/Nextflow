#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads = "$baseDir/raw_data/*_{}.fastq.gz"
params.outdir = "$baseDir/results"

// Define the channel for input FastQ files
input_fastq_channel = Channel.fromPath(params.reads)

// Process that trims the input FastQ files using Trimmomatic
process TrimReads {
    // Tag each job with the pair identifier
    tag "${pair_id}"

    // Specifies where to place the output files
    publishDir "${params.outdir}/trimmed", mode: 'copy'

    // Declare expected inputs (a tuple with a pair identifier and paths to the two FastQ files)
    input:
    tuple val(pair_id), path(read1), path(read2) 

    // Specifies the output files (trimmed FastQ files)
    output:
    tuple val(pair_id), path("${pair_id}_R1.trimmed.fastq.gz"), path("${pair_id}_R2.trimmed.fastq.gz")

    // Contains the command to run Trimmomatic, including parameters for paired-end trimming and quality filtering
    script:
    """
    fastp \\
        -i $read1 \\
        -I $read2 \\
        -o ${pair_id}_R1.trimmed.fastq.gz \\
        -O ${pair_id}_R2.trimmed.fastq.gz \\
        --trim_poly_g \\
        --qualified_quality_phred 15 \\
        --length_required 36
    """
}

// Define the second step: FastA assembler
//process assemble {
    //input:
   // file(trimmed_fastq) from trimmed_ch

   // output:
   // file('assembled.fasta')

   // script:
    //"""
   // # Command to assemble FastA sequences (replace with actual command)
   // # Example: assemble_sequences.py trimmed_fastq -o assembled.fasta
 //   """
//}
// Defines a process for assembling the trimmed reads into contigs using SPAdes
process AssembleFasta {

    //block declares the inputs (a tuple with a pair identifier and paths to the two trimmed FastQ files)
    tag "${pair_id}"
    
    //specifies where to place the output files
    publishDir "${params.outdir}/assembly", mode: 'copy'

    //block declares the inputs (a tuple with a pair identifier and paths to the two trimmed FastQ files)
    input:
    tuple val(pair_id), path(r1_trimmed), path(r2_trimmed)

    //block specifies the output (the assembly result)
    output:
    path("${pair_id}.assembly")

    //block contains the command to run SPAdes with the trimmed reads as input
    script:
    """
    spades.py -1 $r1_trimmed -2 $r2_trimmed -o ${pair_id}.assembly
    """
}


//Defines the workflow block that orchestrates the execution of the defined processes
workflow {
    //create Channel from paired-end read files using the Channel.fromFilePairs method with the params.reads pattern
    read_pairs = Channel.fromFilePairs(params.reads, size: 2, flat: true)

    //captures the output from the TrimReads process, which is then piped into the AssembleFasta process
    trimmed_reads = read_pairs
        | TrimReads

    assembled_fasta = trimmed_reads
        | AssembleFasta

    // output of AssembleFasta is stored in the assembled_fasta variable, 
    //which is then used to display a completion message for each assembled fasta file using the .view method
    assembled_fasta
        .view { it -> "Assembly completed: ${it}" }
}
// Define the channel for trimmed FastQ files
//trimmed_ch = Channel.fromPath("${params.outdir}/trimmed/*_R1.trimmed.fastq.gz")

// Define workflow
//workflow {
    // Connect the processes sequentially
   // TrimReads(input_fastq_channel)
    //assemble(trimmed_ch)
//}
