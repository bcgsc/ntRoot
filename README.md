[![Release](https://img.shields.io/github/release/bcgsc/ntRoot.svg)](https://github.com/bcgsc/ntRoot/releases)
[![link](https://img.shields.io/badge/ntRoot-preprint-brightgreen)](https://www.biorxiv.org/content/10.1101/2024.03.26.586646v1)
[![Zenodo](https://img.shields.io/badge/ntRoot-zenodo-red)](https://zenodo.org/doi/10.5281/zenodo.10869033)
[![Conda](https://img.shields.io/conda/dn/bioconda/ntroot?label=Conda)](https://anaconda.org/bioconda/ntroot)

![Logo](https://github.com/bcgsc/ntRoot/blob/main/ntroot-logo_colors.png)

# ntRoot

Ancestry inference from genomic data

## Contents

1. [Credit](#credit)
2. [Description](#description)
3. [Installation](#install)
4. [Dependencies](#dependencies)
5. [Usage](#usage)
6. [Human ancestry predictions](#data)
7. [Demo](#demo)
8. [Documentation](#docs)	
9. [Citing](#citing)
10. [License](#license)

## Credit  <a name=credit></a>
Written by René L Warren and Lauren Coombe

## Description <a name=description></a>
ntRoot is a framework for ancestry inference from genomic data, offering both Local Ancestry Inference (LAI) and Global Ancestry Inference (GAI). Leveraging integrated variant call sets from the 1000 Genomes Project (1kGP), ntRoot provides accurate predictions(1) of human super-population ancestry with speed and efficiency from Whole Genome Sequencing (WGS) datasets and complete or draft-stage Whole Genome Assemblies (WGA). Through streamlined processing and flexible genomic input, ntRoot holds promises for human ancestry inference of small-to-large patient/individual cohorts, enabling association studies with demographics and facilitating deeper insights into population genetics and disease risk factors.

(1) Tested on base-accurate quality data, including Illumina short read and PacBio CCS HiFi long read datasets, complete reference genomes and polished, Oxford Nanopore Technology long read Flye and Shasta draft genome assemblies 

## Installation <a name=install></a>

Installing ntRoot using conda (recommended):
```
conda install -c bioconda -c conda-forge ntroot
```

Installing ntRoot from the source code:
```
git clone https://github.com/bcgsc/ntRoot.git
cd ntRoot
```
No compilation is required for ntRoot (only the dependencies), so simply add the ntRoot repository to your PATH.

### Dependencies <a name=dependencies></a>
- python 3.9+
- perl
- [ntEdit 2.0.2+](https://github.com/bcgsc/ntEdit)
- [snakemake](https://snakemake.readthedocs.io/en/stable/)
- [samtools](https://www.htslib.org/)
- [bedtools](https://bedtools.readthedocs.io/en/latest/)


## Usage <a name=usage></a>
```
usage: ntroot [-h] [-r REFERENCE] [--reads READS] [--genome GENOME [GENOME ...]] -l L [-k K] [--tile TILE] [--lai] [-t T] [-z Z] [-j J] [-Y Y] [--custom_vcf CUSTOM_VCF]
              [--strip_info] [-v] [-V] [-n] [-f]

ntRoot: Ancestry inference from genomic data

optional arguments:
  -h, --help            show this help message and exit
  -r REFERENCE, --reference REFERENCE
                        Reference genome (FASTA, Multi-FASTA, and/or gzipped compatible)
  --reads READS         Prefix of input reads file(s) for detecting SNVs. All files in the working directory with the specified prefix will be used. (fastq, fasta, gz, bz, zip)
  --genome GENOME [GENOME ...]
                        Genome assembly file(s) for detecting SNVs compared to --reference
  -l L                  input VCF file with annotated variants (e.g., clinvar.vcf)
  -k K                  k-mer size
  --tile TILE           Tile size for ancestry fraction inference (bp) [default=5000000]
  --lai                 Output ancestry predictons per tile in a separate output file
  -t T                  Number of threads [default=4]
  -z Z                  Minimum contig length [default=100]
  -j J                  controls size of k-mer subset. When checking subset of k-mers, check every jth k-mer [default=3]
  -Y Y                  Ratio of number of k-mers in the k subset that should be present to accept an edit (higher=stringent) [default=0.55]
  --custom_vcf CUSTOM_VCF
                        Input VCF for computing ancestry. When specified, ntRoot will skip the ntEdit step, and predict ancestry from the provided VCF.
  --strip_info          When using --custom_vcf, strip the existing INFO field from the input VCF.
  -v, --verbose         Verbose mode [default=False]
  -V, --version         show program's version number and exit
  -n, --dry-run         Print out the commands that will be executed
  -f, --force           Run all ntRoot steps, regardless of existing output files

Note: please specify --reads OR --genome (not both)
If you have any questions about ntRoot, please open an issue at https://github.com/bcgsc/ntRoot
```

## Human ancestry predictions <a name=data></a>

Using the 1kGP integrated variant call set.

Download this archive:
<pre>
wget https://zenodo.org/records/10976332/files/ntroot_supplementary_zenodo.tar.gz
</pre>
  
from:
<pre>
https://zenodo.org/doi/10.5281/zenodo.10869033
</pre>

unzip and untar:
<pre>
tar xvzf ntroot_supplementary_zenodo.tar.gz
</pre>

access the files:
<pre>
cd ./ntroot_supplementary_zenodo/data
ls

1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz
GRCh38.fa.gz
readme
</pre>


Users will specify:
<pre>
ntroot --reference GRCh38.fa.gz (--reads FILE_PREFIX OR --genome FILE) -l 1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz -k 55
</pre>

Example command:
<pre>
ntroot -k 55 --reference GRCh38.fa.gz --reads ERR3242308_ -t 48 -Y 0.55 -l 1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz
</pre>

If you would like to infer ancestry from a pre-existing VCF file:
<pre>
ntroot -r GRCh38.fa.gz --custom_vcf third_party.vcf -l 1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz
</pre>

Note: For more advanced users, and for ancestry predictions on organisms other than human, please contact us.


![Phylogenetic analysis of ntRoot ancestry-discriminant SNVs from a 1kGP sample set (n=153)](https://github.com/bcgsc/ntRoot/blob/main/ntroot_family_siblings.png)
Neighbor joining phylogenetic analysis of ntRoot ancestry-discriminant SNVs for 153, 1000 Genomes Project (1kGP) individuals from 5 global regions (EAS=East Asia, EUR=Europe, SAS=South Asia, AFR=Africa, AMR=America). Branches are colored by the 1kGP super-population labels, with the pie charts at each leaf indicating the ntRoot-estimated ancestry composition of each individual, based on ntRoot (v1.0.1; -k 55 --draft GRCh38.fa.gz --reads 1kGP_WGS.fq -t 48 -Y 0.55 -l 1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz) local ancestry inference (LAI). Highlighted sections show family trios (Mother-Father-Child), with a more complexed family relationship shown for 3 EAS siblings (sister with 2 brothers, each parent in a trio). The 1kGP accessions are shown on the outer ring label track with the 1kGP sub-population labels (CLM:Colombian; MXL:Mexican-American; PEL:Peruvian; PUR:Puerto Rican; ACB:African-Caribbean; ESN:Esan; GWD:Gambian; LWK:Luhya; MSL:Mende; YRI:Yoruba; CEU:CEPH (Centre d’Étude du Polymorphisme Humain – Utah); FIN:Finnish; GBR:British; IBS:Spanish; TSI:Tuscan; BEB:Bengali; ITU:Indian; PJL:Punjabi; STU:Sri Lankan; CDX:Dai Chinese; CHS:Southern Han Chinese; KHV:Kinh Vietnamese) on the inner-most label track. This figure is for illustrative purposes, demonstrating a possible application of ntRoot and its robust LAI. Note: Certain individuals with AMR 1kGP labels (e.g., PUR) are [known to be admixed, with primarily African ancestry](https://academic.oup.com/genetics/article/220/2/iyab227/6460343?login=false) and, accordingly, cluster at the edge of the AMR and AFR clades in the phylogeny.


## Demo <a name=demo></a>
To test your installation:
```
cd demo
./run_ntroot_demo.sh
```
Ensure that the ntRoot installation is available on your PATH.


## Documentation <a name=docs></a>

Refer to the README.md file on how to install and run ntRoot.
Our [preprint](https://www.biorxiv.org/content/10.1101/2024.03.26.586646v1) contains information about the software and its performance.
![ntRoot PSB poster](https://github.com/bcgsc/ntRoot/blob/main/ntRootPSB2025.png)
This [PSB2025 poster](https://doi.org/10.5281/zenodo.13844277) contains additional information, benchmarks and results.



## Citing <a name=citing></a>

Thank you for your [![Stars](https://img.shields.io/github/stars/bcgsc/ntRoot.svg)](https://github.com/bcgsc/ntRoot/stargazers) and for using and promoting this free software! We hope that ntRoot is useful to you and your research.

If you use ntRoot, please cite:

[ntRoot: human ancestry inference at scale, from genomic data](https://doi.org/10.1101/2024.03.26.586646)
<pre>
Human ancestry inference at scale, from genomic data
Warren RL, Coombe L, Wong J, Kazemi P, Birol I.
bioRxiv 2024.03.26.586646; doi: https://doi.org/10.1101/2024.03.26.586646
</pre>

## License <a name=license></a>

ntRoot Copyright (c) 2024-present British Columbia Cancer Agency Branch.  All rights reserved.

ntRoot is released under the GNU General Public License v3

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

For commercial licensing options, please contact
Patrick Rebstein <prebstein@bccancer.bc.ca>
