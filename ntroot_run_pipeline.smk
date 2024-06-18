#!/usr/bin/env snakemake -s

# Snakefile for ntRoot pipeline
import os
import shutil

onsuccess:
    shutil.rmtree(".snakemake", ignore_errors=True)

# Read parameters from config or set default values
reference=config["reference"]
draft_base = os.path.basename(os.path.realpath(reference))
reads_prefix=config["reads"] if "reads" in config else ""
k=config["k"] if "k" in config else None

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

# Third-party VCF parameters
input_vcf = config["input_vcf"] if "input_vcf" in config else None
input_vcf_basename = os.path.basename(os.path.realpath(input_vcf)) if input_vcf else "None"

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

rule ntroot_input_vcf:
    input: f"{input_vcf_basename}.cross-ref.vcf_ancestry-predictions_tile{tile_size}.tsv"

rule ntroot_input_vcf_lai:
    input: f"{input_vcf_basename}.cross-ref.vcf_ancestry-predictions-tile-resolution_tile{tile_size}.tsv"

rule ntedit_reads:
    input: 
        reference = reference
    output:
        out_vcf = f"{reads_prefix}_ntedit_k{k}_variants.vcf",
        out_fa = temp(f"{reads_prefix}_ntedit_k{k}_edited.fa"),
        out_changes = temp(f"{reads_prefix}_ntedit_k{k}_changes.tsv"),
        out_bf = temp(f"{reads_prefix}_k{k}.bf")
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} -t {t} -z {z} -j {j} -Y {Y} --solid ",
        vcf_input = f"-l {l}" if l else ""
    shell:
        "{params.benchmark} run-ntedit snv --reference {reference} --reads {reads_prefix} {params.params} "
        "{params.vcf_input}"

rule ntedit_genome:
    input: 
        reference = reference,
        genomes = genomes
    output:
        out_vcf = f"{genome_prefix}_ntedit_k{k}_variants.vcf",
        out_fa = temp(f"{genome_prefix}_ntedit_k{k}_edited.fa"),
        out_changes = temp(f"{genome_prefix}_ntedit_k{k}_changes.tsv"),
        out_bf = temp(f"{genome_prefix}_k{k}.bf")
    params:
        benchmark = f"{time_command} ntedit_snv_k{k}.time",
        params = f"-k {k} -t {t} -z {z} -j {j} -Y {Y}",
        vcf_input = f"-l {l}" if l else ""
    shell:
        "{params.benchmark} run-ntedit snv --reference {reference} --genome {input.genomes} {params.params} "
        " {params.vcf_input}"

rule samtools_faidx:
    input: reference = reference
    output: out_fai = f"{draft_base}.fai"
    params:
        benchmark = f"{time_command} samtools_faidx_{draft_base}.time"
    shell:
        "{params.benchmark} samtools faidx -o {output.out_fai} {input.reference}"

rule ancestry_prediction:
    input: 
        vcf = "{vcf}"
    output: 
        predictions = "{vcf}_ancestry-predictions_tile{tile_size}.tsv"
    params:
        benchmark = f"{time_command} ancestry_prediction_tile{tile_size}.time" if input_vcf_basename else f"{time_command} ancestry_prediction_k{k}_tile{tile_size}.time",
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
        benchmark = f"{time_command} ancestry_prediction_tile{tile_size}.time" if input_vcf_basename else f"{time_command} ancestry_prediction_k{k}_tile{tile_size}.time",
        tile_size = tile_size,
        verbosity = v
    shell:
        "{params.benchmark} ntRootAncestryPredictor.pl -f {input.vcf} -t {params.tile_size} -v {params.verbosity} -r 1 -i {input.ref_fai}"

rule sort_vcf_input:
    input: vcf = f"{input_vcf}"
    output: vcf_sorted = temp(f"{input_vcf_basename}_sorted.vcf")
    params:
        benchmark = f"{time_command} sort_vcf_{input_vcf_basename}.time"
    shell:
        """{params.benchmark} sh -c '(echo "##fileformat=VCFv4.2" ; cat {input.vcf} |grep -v "#" |sort -k1,1 -k2,2n) > {output.vcf_sorted}'"""

rule sort_vcf_l:
    input: vcf = l
    output: temp(f"{os.path.basename(os.path.realpath(l))}_sorted.tmp.vcf")
    params:
        benchmark = f"{time_command} sort_vcf_l.time",
        cat_cmd = "gunzip -c" if f"{l}".endswith(".gz") else "cat"
    shell:
        """{params.benchmark} sh -c '(echo "##fileformat=VCFv4.2" ; {params.cat_cmd} {input.vcf} |grep -v "#" |sort -k1,1 -k2,2n) > {output}'"""

rule bedtools_intersect:
    input:         
        sorted_vcf = f"{input_vcf_basename}_sorted.vcf",
        sorted_ref_vars = f"{os.path.basename(os.path.realpath(l))}_sorted.tmp.vcf"
    output:
        bedtools = temp(f"{input_vcf_basename}.bedtools-intersect.bed")
    params:
        benchmark = f"{time_command} bedtools_intersect_{input_vcf_basename}.time"
    shell:
        "{params.benchmark} bedtools intersect -loj -sorted -a {input.sorted_vcf} -b {input.sorted_ref_vars} > {output.bedtools}"

rule cross_reference_vcf:
    input: 
        vcf = f"{input_vcf}",
        ref_vars = l,
        bedtools = f"{input_vcf_basename}.bedtools-intersect.bed"
    output: f"{input_vcf_basename}.cross-ref.vcf"
    params:
        benchmark = f"{time_command} cross_reference_vcf_{input_vcf_basename}.time",
        prefix=f"{input_vcf_basename}.cross-ref"
    shell: 
        "{params.benchmark} ntroot_cross_reference_vcf.py -b {input.bedtools} --vcf {input.vcf} --vcf_l {input.ref_vars} -p {params.prefix}"