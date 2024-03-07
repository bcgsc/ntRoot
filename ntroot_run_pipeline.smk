#!/usr/bin/env snakemake -s

# Snakefile for ntRoot pipeline
import os
import shutil

onsuccess:
    shutil.rmtree(".snakemake", ignore_errors=True)

# Read parameters from config or set default values
draft=config["draft"]
reads_prefix=config["reads"] if "reads" in config else ""
k=config["k"]

genomes = config["genomes"] if "genomes" in config else ""
genome_prefix = ".".join([os.path.basename(os.path.realpath(genome)).removesuffix(".fa").removesuffix(".fasta").removesuffix(".fna") for genome in genomes])

# Common parameters
t = config["t"] if "t" in config else 4
b = config["b"] + "_" if "b" in config and config["b"] != "" else ""

# ntHits parameters
solid = config["solid"] if "solid" in config else False
cutoff = config["cutoff"] if "cutoff" in config else 2

# ntEdit parameters
z = config["z"] if "z" in config else 100
y = config["y"] if "y" in config else 9.000
v = config["v"] if "v" in config else 0
j = config["j"] if "j" in config else 3
X = config["X"] if "X" in config else -1
Y = config["Y"] if "Y" in config else -1
p = config["p"] if "p" in config else 1
q = config["q"] if "q" in config else 255
l = config["l"] if "l" in config else ""
bloomType = config["bloomType"] if "bloomType" in config else "bf"

# Ancestry inference parameters
window_size = config["window_size"] if "window_size" in config else 5000000

# time command
mac_time_command = "command time -l -o"
linux_time_command = "command time -v -o"
time_command = mac_time_command if os.uname().sysname == "Darwin" else linux_time_command

rule all:
    input: f"{reads_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions.tsv"

rule ntroot_genome:
    input: f"{genome_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions.tsv"

rule ntroot_reads:
    input: f"{reads_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions.tsv"

rule ntedit_reads:
    input: 
        draft = draft
    output:
        out_vcf = f"{reads_prefix}_ntedit_k{k}_variants.vcf" if bloomType == "bf" else f"{reads_prefix}_ntedit_k{k}_cbf_variants.vcf"
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} --bloomType {bloomType} -t {t} -z {z} -y {y} -j {j} -p {p} -q {q} ",
        vcf_input = f"-l {l}" if l else "",
        cutoff = "--solid" if solid else f"--cutoff {cutoff}",
        verbosity = "-v" if v else "",
        ratio = f"-X {X} -Y {Y}" if X != -1 or Y != -1 else ""
    shell:
        "{params.benchmark} run-ntedit snv --draft {draft} --reads {reads_prefix} {params.params}"
        "{params.vcf_input} {params.cutoff} {params.verbosity} {params.ratio}"

rule ntedit_genome:
    input: 
        draft = draft,
        genomes = genomes
    output:
        out_vcf = f"{genome_prefix}_ntedit_k{k}_variants.vcf"
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} -t {t} -z {z} -y {y} -j {j} -p {p} -q {q}",
        vcf_input = f"-l {l}" if l else "",
        verbosity = "-v" if v else "",
        ratio = f"-X {X} -Y {Y}" if X != -1 or Y != -1 else ""
    shell:
        "{params.benchmark} run-ntedit snv --draft {draft} --genome {input.genomes} {params.params}"
        " {params.vcf_input} {params.verbosity} {params.ratio}"


rule ancestry_prediction:
    input: 
        vcf = "{vcf}"
    output: 
        predictions = "{vcf}_ancestry-predictions.tsv"
    params:
        benchmark = f"{time_command} ancestry_prediction_k{k}.time",
        window_size = window_size
    shell:
        "{params.benchmark} ntRootAncestryPredictor.pl {input.vcf} {params.window_size}"

