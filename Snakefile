import os
import pandas as pd
# getting the samples information (names, path to r1 & r2) from samples.txt
samples_information = pd.read_csv("samples.txt", sep='\t', index_col=False)
# get a list of the sample names
sample_names = list(samples_information['sample'])
sample_locations = list(samples_information['location'])
samples_set = zip(sample_names, sample_locations)
samples_dict = dict(zip(sample_names, sample_locations))
# Rules -----------------------------------------------------------------------

rule all:
    input:
        expand('{sample}_{pair}_fastqc.{ext}', sample=sample_names, pair=['R1', 'R2'], ext=['html', 'zip']),

def getHome(sample):
  return(list(os.path.join(samples_dict[sample],"{0}_{1}.fastq.gz".format(sample,pair)) for pair in ['R1','R2']))


rule qc_before_trim:
    input:
        r1 = lambda wildcards: getHome(wildcards.sample)[0],
        r2 = lambda wildcards: getHome(wildcards.sample)[1]
    output:
        "{sample}_R1_fastqc.html",
        "{sample}_R1_fastqc.zip",
        "{sample}_R2_fastqc.html",
        "{sample}_R2_fastqc.zip"
    resources:
        mem = 1000,
        time = 30
    threads: 1
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell: """
        #module load fastqc/0.11.5;
        fastqc -o ./ -f fastq {input.r1} &
        fastqc -o ./ -f fastq {input.r2}
        """