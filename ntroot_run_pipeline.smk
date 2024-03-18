#!/usr/bin/env snakemake -s

# Snakefile for ntRoot pipeline
import os
import shutil

onsuccess:
    shutil.rmtree(".snakemake", ignore_errors=True)

# Read parameters from config or set default values
draft=config["draft"]
draft_base = os.path.basename(os.path.realpath(draft))
reads_prefix=config["reads"] if "reads" in config else ""
k=config["k"]

genomes = config["genomes"] if "genomes" in config else ""
genome_prefix = ".".join([os.path.basename(os.path.realpath(genome)).removesuffix(".fa").removesuffix(".fasta").removesuffix(".fna") for genome in genomes])

# Common parameters
t = config["t"] if "t" in config else 4
b = config["b"] + "_" if "b" in config and config["b"] != "" else ""


# ntEdit parameters
z = config["z"] if "z" in config else 100
v = config["v"] if "v" in config else 0
j = config["j"] if "j" in config else 3
Y = config["Y"] if "Y" in config else 0.55
l = config["l"] if "l" in config else ""

# Ancestry inference parameters
tile_size = config["tile_size"] if "tile_size" in config else 5000000

# time command
mac_time_command = "command time -l -o"
linux_time_command = "command time -v -o"
time_command = mac_time_command if os.uname().sysname == "Darwin" else linux_time_command

rule all:
    input: f"{reads_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions_tile{tile_size}.tsv"

rule ntroot_genome:
    input: f"{genome_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions_tile{tile_size}.tsv"

rule ntroot_reads:
    input: f"{reads_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions_tile{tile_size}.tsv"

rule ntroot_genome_lai:
    input: f"{genome_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions-tile-resolution_tile{tile_size}.tsv"

rule ntroot_reads_lai:
    input: f"{reads_prefix}_ntedit_k{k}_variants.vcf_ancestry-predictions-tile-resolution_tile{tile_size}.tsv"

rule ntedit_reads:
    input: 
        draft = draft
    output:
        out_vcf = f"{reads_prefix}_ntedit_k{k}_variants.vcf"
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} -t {t} -z {z} -j {j} -Y {Y} --solid ",
        vcf_input = f"-l {l}" if l else ""
    shell:
        "{params.benchmark} run-ntedit snv --draft {draft} --reads {reads_prefix} {params.params} "
        "{params.vcf_input}"

rule ntedit_genome:
    input: 
        draft = draft,
        genomes = genomes
    output:
        out_vcf = f"{genome_prefix}_ntedit_k{k}_variants.vcf"
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} -t {t} -z {z} -j {j} -Y {Y}",
        vcf_input = f"-l {l}" if l else ""
    shell:
        "{params.benchmark} run-ntedit snv --draft {draft} --genome {input.genomes} {params.params} "
        " {params.vcf_input}"

rule samtools_faidx:
    input: draft = draft
    output: out_fai = f"{draft_base}.fai"
    params:
        benchmark = f"{time_command} samtools_faidx_{draft_base}.time"
    shell:
        "{params.benchmark} samtools faidx -o {output.out_fai} {input.draft}"

rule ancestry_prediction:
    input: 
        vcf = "{vcf}"
    output: 
        predictions = "{vcf}_ancestry-predictions_tile{tile_size}.tsv"
    params:
        benchmark = f"{time_command} ancestry_prediction_k{k}_tile{tile_size}.time",
        tile_size = tile_size,
        verbosity = v
    shell:
        "{params.benchmark} ntRootAncestryPredictor.pl -f {input.vcf} -t {params.tile_size} -v {params.verbosity}"


rule ancestry_prediction_lai:
    input: 
        vcf = "{vcf}",
        ref_fai = f"{draft_base}.fai"
    output: 
        lai_output = "{vcf}_ancestry-predictions-tile-resolution_tile{tile_size}.tsv"
    params:
        benchmark = f"{time_command} ancestry_prediction_k{k}_tile{tile_size}.time",
        tile_size = tile_size,
        verbosity = v
    shell:
        "{params.benchmark} ntRootAncestryPredictor.pl -f {input.vcf} -t {params.tile_size} -v {params.verbosity} -r 1 -i {input.ref_fai}"

