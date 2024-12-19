params.inFile1 = file(args[0])
params.inFile2 = file(args[1])
params.outputDir = "$baseDir"
//skesa assembly files here
process skesa {
    maxForks 1
    publishDir(params.outputDir, mode: 'copy')

    input:
    file inFile1
    file inFile2

    output:
    path "skesa_assembly.fna", emit: skesaOut

    script:
    """
    skesa --reads $inFile1 $inFile2 --contigs_out skesa_assembly.fna 1> skesa.stdout.txt 2> skesa.stderr.txt
    """
}
//check for the quality assesment
process checkm {
    maxForks 1
    publishDir(params.outputDir, mode: 'copy')
    errorStrategy 'ignore'

    input:
    path skesaAssembly

    output:
    path "checkm_results", optional: true

    script:
    """
    source /home/hpatil39/anaconda3/etc/profile.d/conda.sh
    conda activate checkm

    checkm lineage_wf -x fna $skesaAssembly checkm_results 1> checkm.stdout.txt 2> checkm.stderr.txt || echo "checkm failed"
    """
}
//mlst used in genotype here
process genotype {
    maxForks 3
    publishDir("${params.outdir}", mode: 'copy')
    input:
        path asm
    script:
        """
        mlst $asm > MLST_Summary.tsv
        """
}

workflow {
    inFile1_ch = Channel.fromPath(params.inFile1)
    inFile2_ch = Channel.fromPath(params.inFile2)
    skesa_assembly = skesa(inFile1_ch, inFile2_ch)
    checkm_results = checkm(skesa_assembly.skesaOut)
    genotyping = genotype(skesa_assembly.skesaOut)
}