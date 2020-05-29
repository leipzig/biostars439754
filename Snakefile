# Directories------------------------------------------------------------------
configfile: "config.yaml"

# Setting the names of all directories
dir_list = ["LOG_DIR", "BENCHMARK_DIR", "QC_DIR", "TRIM_DIR", "ALIGN_DIR", "MARKDUP_DIR", "CALLING_DIR", "ANNOT_DIR"]
dir_names = ["LOGS", "BENCHMARKS", "QC", "TRIMMING", "ALIGNMENT", "MARK_DUPLICATES", "VARIANT_CALLING", "ANNOTATION"]
dirs_dict = dict(zip(dir_list, dir_names))

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
        expand('{QC_DIR}/{QC_TOOL}/before_trim/{sample}_{pair}_fastqc.{ext}', QC_DIR=dirs_dict["QC_DIR"], QC_TOOL=config["QC_TOOL"], sample=sample_names, pair=['R1', 'R2'], ext=['html', 'zip']),

def getHome(sample):
  return(list(os.path.join(samples_dict[sample],"{0}_{1}.fastq.gz".format(sample,pair)) for pair in ['R1','R2']))


rule qc_before_trim:
    input:
        r1 = lambda wildcards: getHome(wildcards.sample)[0],
        r2 = lambda wildcards: getHome(wildcards.sample)[1]
    output:
        os.path.join(dirs_dict["QC_DIR"],config["QC_TOOL"],"before_trim","{sample}_R1_fastqc.html"),
        os.path.join(dirs_dict["QC_DIR"],config["QC_TOOL"],"before_trim","{sample}_R1_fastqc.zip"),
        os.path.join(dirs_dict["QC_DIR"],config["QC_TOOL"],"before_trim","{sample}_R2_fastqc.html"),
        os.path.join(dirs_dict["QC_DIR"],config["QC_TOOL"],"before_trim","{sample}_R2_fastqc.zip")
    params:
        dir = os.path.join(dirs_dict["QC_DIR"],config["QC_TOOL"],'before_trim')
    resources:
        mem = 1000,
        time = 30
    threads: 1
    message: """--- Quality check of raw data with FastQC before trimming."""
    shell: """
        #module load fastqc/0.11.5;
        fastqc -o {params.dir} -f fastq {input.r1} &
        fastqc -o {params.dir} -f fastq {input.r2}
        """
