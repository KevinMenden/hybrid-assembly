# hybrid-assembly
Pipeline for hybrid assembly using short and long reads.

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

## Pipeline overview
The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using some of the following steps, depending on which assembly tool was chosen:

* [FastQC](#fastqc) - short read quality control
* [NanoPlot](#nanoplot) - long read quality control
* [SPAdes](#spades) - hybrid assembly
* [Canu](#canu) - long read assembly
* [minimap2](#minimap2) - mapping of short reads to assembly
* [pilon](#pilon) - Polishing of long read assembly using mapped short reads
* [QUAST](#quast) - Assembly statistics and quality
* [MultiQC](#multiqc) - aggregate report, describing results of the whole pipeline

## FastQC
[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your reads. It provides information about the quality score distribution across your reads, the per base sequence content (%T/A/G/C). You get information about adapter contamination and other overrepresented sequences.

For further reading and documentation see the [FastQC help](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

**Output directory: `results/fastqc`**

* `sample_fastqc.html`
  * FastQC report, containing quality metrics for your untrimmed raw fastq files
* `zips/sample_fastqc.zip`
  * zip file containing the FastQC report, tab-delimited data file and plot images

## NanoPlot
[NanoPlot](https://github.com/wdecoster/NanoPlot) is a set of scripts to generate quality control statistics and plots for Oxford Nanopore
long reads.

**Output directory: `results/nanoqc`**

## SPAdes
[SPAdes](http://cab.spbu.ru/software/spades/) is a versatile de novo genome assembly tool that allows to use both
short and long reads for assembly.

**Output directory: `results/spades_results`**

## Canu
[Canu](https://github.com/marbl/canu) is a assembly tool specifically developed for long read technologies.

**Output directory: `results/canu`**

## minimap2
[minimap2](https://github.com/lh3/minimap2) is a versatile mapping tool that can map short and long reads.

**Output directory: `results/minimap2`**

## pilon
[pilon](https://github.com/broadinstitute/pilon) can be used to improve the quality of assemblies generated with long
reads using more accurate short reads.

**Output directory: `results/pilon`**

## MaSuRCA
[MaSuRCA](https://github.com/alekseyzimin/masurca) uses superreads and megareads to integrate short and long reads
for de novo assembly.

**Output direcetory: `results/masurca`**

## QUAST
[QUAST](http://quast.sourceforge.net/quast) is a tool for assessing quality statistics of genome assemblies.

**Output directory: `results/quast_results`**

## MultiQC
[MultiQC](http://multiqc.info) is a visualisation tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in within the report data directory.

**Output directory: `results/multiqc`**

* `Project_multiqc_report.html`
  * MultiQC report - a standalone HTML file that can be viewed in your web browser
* `Project_multiqc_data/`
  * Directory containing parsed statistics from the different tools used in the pipeline

For more information about how to use MultiQC reports, see http://multiqc.info
