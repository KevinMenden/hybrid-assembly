#!/usr/bin/env nextflow
/*
========================================================================================
                         hybrid-assembly
========================================================================================
 hybrid-assembly Analysis Pipeline. Started 2018-03-20.
 #### Homepage / Documentation
 https://github.com/kevinmenden/hybrid-assembly
 #### Authors
 Kevin Menden kevinmenden <kevin.menden@t-online.de> - https://github.com/kevinmenden>
----------------------------------------------------------------------------------------
*/


def helpMessage() {
    log.info"""
    =========================================
     hybrid-assembly v${params.version}
    =========================================
    Usage:

    The typical command for running the pipeline is as follows:

    nextflow run kevinmenden/hybrid-assembly --shortReads '*_R{1,2}.fastq.gz' --longReads 'nano_reads.fastq.gz' --assembler spades  -profile docker

    Mandatory arguments:
      --assembler                   The assembler pipeline to choose. One of 'spades' | 'canu' | 'masurca'
      --shortReads                  The paired short reads
      --longReads                   The long reads
      -profile                      Hardware config to use. docker / aws

    References                      If not specified in the configuration file or you wish to overwrite any of the references.
      --fasta                       Path to Fasta reference

    Other options:
      --outdir                      The output directory where the results will be saved
      --email                       Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits
      -name                         Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.
    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help emssage
if (params.help){
    helpMessage()
    exit 0
}

// Configurable variables
params.name = false
params.fasta = params.genome ? params.genomes[ params.genome ].fasta ?: false : false
params.shortReads = ""
params.longReads = ""
params.multiqc_config = "$baseDir/conf/multiqc_config.yaml"
params.email = false
params.plaintext_email = false
params.assembler = "spades"

multiqc_config = file(params.multiqc_config)
output_docs = file("$baseDir/docs/output.md")

// Validate inputs
if ( params.fasta ){
    fasta = file(params.fasta)
    if( !fasta.exists() ) exit 1, "Fasta file not found: ${params.fasta}"
}


// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if( !(workflow.runName ==~ /[a-z]+_[a-z]+/) ){
  custom_runName = workflow.runName
}

/*
 * Create a channel for input short read files
 */
Channel
    .fromFilePairs( params.shortReads )
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nNB: Path requires at least one * wildcard!\nIf this is single-end data, please specify --singleEnd on the command line." }
    .into { short_reads_qc; short_reads_assembly }

/*
 * Create a channel for input long read files
 */
Channel
        .fromFile( params.longReads)
        .ifEmpty { exit 1, "Cannot find any long reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!" }
        .into { long_reads_qc; long_reads_assembly }


// Header log info
log.info "========================================="
log.info " hybrid-assembly v${params.version}"
log.info "========================================="
def summary = [:]
summary['Run Name']     = custom_runName ?: workflow.runName
summary['Short Reads']  = params.shortReads
summary['Long Reads']   = params.longReads
summary['Fasta Ref']    = params.fasta
summary['Max Memory']   = params.max_memory
summary['Max CPUs']     = params.max_cpus
summary['Max Time']     = params.max_time
summary['Output dir']   = params.outdir
summary['Working dir']  = workflow.workDir
summary['Container']    = workflow.container
if(workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Current home']   = "$HOME"
summary['Current user']   = "$USER"
summary['Current path']   = "$PWD"
summary['Script dir']     = workflow.projectDir
summary['Config Profile'] = workflow.profile
if(params.email) summary['E-mail Address'] = params.email
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "========================================="


// Check that Nextflow version is up to date enough
// try / throw / catch works for NF versions < 0.25 when this was implemented
try {
    if( ! nextflow.version.matches(">= $params.nf_required_version") ){
        throw GroovyException('Nextflow version too old')
    }
} catch (all) {
    log.error "====================================================\n" +
              "  Nextflow version $params.nf_required_version required! You are running v$workflow.nextflow.version.\n" +
              "  Pipeline execution will continue, but things may break.\n" +
              "  Please run `nextflow self-update` to update Nextflow.\n" +
              "============================================================"
}


/*
 * Parse software version numbers
 */
process get_software_versions {

    output:
    file 'software_versions_mqc.yaml' into software_versions_yaml

    script:
    """
    echo $params.version > v_pipeline.txt
    echo $workflow.nextflow.version > v_nextflow.txt
    fastqc --version > v_fastqc.txt
    multiqc --version > v_multiqc.txt
    scrape_software_versions.py > software_versions_mqc.yaml
    """
}

/**
 * STEP 1.1 QC for short reads
 */
process fastqc {
    tag "$name"
    publishDir "${params.outdir}/fastqc", mode: 'copy',
        saveAs: {filename -> filename.indexOf(".zip") > 0 ? "zips/$filename" : "$filename"}

    input:
    set val(name), file(reads) from short_reads_qc

    output:
    file "*_fastqc.{zip,html}" into fastqc_results

    script:
    """
    fastqc -q $reads
    """
}

/**
 * STEP 1.2 QC for long reads
 */

/**
 * STEP 2 Assembly
 */

/**
 * SPAdes assembly workflow
 */
if (params.assembler == 'spades') {
    process spades {
        publishDir "${params.outdir}/spades", mode: 'copy'

        input:
        file sreads from short_reads_assembly
        file lreads from long_reads_assembly

        output:
        file "*" into assembly_results

        script:
        """
        spades.py -o ${params.outdir} \\
        --nanopore $lreads \\
        -1 ${sreads[0]} -2 ${sreads[1]}
        """

    }

}

/**
 * Canu assembly workflow
 */
if (params.assembler == 'canu') {

}

/**
 * MaSuRCA assembly workflow
 */
if (params.assembler == 'masurca') {

}

/**
 * STEP 3.1 QUAST assembly QC
 */


/**
 * STEP 3.2 BUSCO assembly QC
 */



/*
 * STEP 2 - MultiQC
 */
process multiqc {
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file ('fastqc/*') from fastqc_results.collect()
    file ('software_versions/*') from software_versions_yaml

    output:
    file "*multiqc_report.html" into multiqc_report
    file "*_data"

    script:
    rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
    rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''
    """
    multiqc -f $rtitle $rfilename --config $multiqc_config .
    """
}



/*
 * Completion e-mail notification
 */
workflow.onComplete {
    log.info "[hybrid-assembly] Pipeline Complete"

}
