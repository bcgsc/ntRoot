[![Release](https://img.shields.io/github/release/bcgsc/ntERoot.svg)](https://github.com/bcgsc/ntRoot/releases)
[![link](https://img.shields.io/badge/ntRoot-preprint-brightgreen)](https://doi.org/10.1101/2024.03.26.586646)
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
6. [Demo](#demo)
7. [Citing](#citing)
8. [License](#license)

## Credit  <a name=credit></a>
Written by René L Warren and Lauren Coombe

## Description <a name=description></a>
ntRoot is a framework for ancestry inference from genomic data, offering both Local Ancestry Inference (LAI) and Global Ancestry Inference (GAI). Leveraging integrated variant call sets from the 1000 Genomes Project (1kGP), ntRoot provides accurate predictions* of super-population ancestry with speed and efficiency from Whole Genome Sequencing (WGS) datasets and complete or draft-stage Whole Genome Assemblies (WGA). Through streamlined processing and flexible genomic input, ntRoot holds promises for human ancestry inference of small-to-large patient/individual cohorts, enabling association studies with demographics and facilitating deeper insights into population genetics and disease risk factors.

*On base-accurate quality data, including Illumina short read and PacBio CCS HiFi long read datasets, complete reference genomes and polished, Oxford Nanopore Technology long read Flye and Shasta draft genome assemblies 

## Installation <a name=install></a>

Installing ntRoot using conda (recommended):
```
conda install -c bioconda -c conda-forge ntroot
```

Installing ntRoot from the source code:
```
git clone --recurse-submodules https://github.com/bcgsc/ntRoot.git
cd ntRoot
meson setup build --prefix=/path/to/install/directory
cd build
ninja install
```
ntRoot and all required scripts will be installed to: /path/to/install/directory

### Dependencies <a name=dependencies></a>
- python 3.9+
- perl
- [meson](https://mesonbuild.com/)
- [ninja](https://ninja-build.org/)
- [snakemake](https://snakemake.readthedocs.io/en/stable/)
- [btllib](https://github.com/bcgsc/btllib)
- [boost](https://www.boost.org/doc/libs/1_61_0/more/getting_started/unix-variants.html)
- [ntCard](https://github.com/bcgsc/ntCard)
- [ntHits](https://github.com/bcgsc/ntHits)
- [samtools](https://www.htslib.org/)

## Usage <a name=usage></a>
```
usage: ntroot [-h] --draft DRAFT [--reads READS] [--genome GENOME [GENOME ...]] -l L -k K [--tile TILE] [--lai] [-t T] [-z Z] [-j J] [-Y Y] [-v] [-V] [-n] [-f]

ntRoot: Ancestry inference from genomic data

optional arguments:
  -h, --help            show this help message and exit
  --draft DRAFT         Draft genome assembly (FASTA, Multi-FASTA, and/or gzipped compatible)
  --reads READS         Prefix of input reads file(s) for detecting SNVs. All files in the working directory with the specified prefix will be used. (fastq, fasta, gz, bz, zip)
  --genome GENOME [GENOME ...]
                        Genome assembly file(s) for detecting SNVs on --draft
  -l L                  input VCF file with annotated variants (e.g., clinvar.vcf)
  -k K                  k-mer size
  --tile TILE           Tile size for ancestry fraction inference (bp) [default=5000000]
  --lai                 Output ancestry predictons per tile in a separate output file
  -t T                  Number of threads [default=4]
  -z Z                  Minimum contig length [default=100]
  -j J                  controls size of k-mer subset. When checking subset of k-mers, check every jth k-mer [default=3]
  -Y Y                  Ratio of number of k-mers in the k subset that should be present to accept an edit (higher=stringent) [default=0.55]
  -v, --verbose         Verbose mode [default=False]
  -V, --version         show program's version number and exit
  -n, --dry-run         Print out the commands that will be executed
  -f, --force           Run all ntRoot steps, regardless of existing output files

Note: please specify --reads OR --genome (not both)
If you have any questions about ntRoot, please open an issue at https://github.com/bcgsc/ntRoot
```

## Demo <a name=demo></a>
To test your installation:
```
cd demo
./run_ntroot_demo.sh
```
Ensure that the ntRoot installation is available on your PATH.

## Citing <a name=citing></a>

Thank you for your [![Stars](https://img.shields.io/github/stars/bcgsc/ntRoot.svg)](https://github.com/bcgsc/ntRoot/stargazers) and for using and promoting this free software! We hope that ntRoot is useful to you and your research.

If you use ntRoot, please cite:

[ntRoot: human ancestry inference at scale, from genomic data](https://doi.org/10.1101/2024.03.26.586646)
<pre>
Human ancestry inference at scale, from genomic data
Warren RL, Coombe L, Wong J, Kazemi P, Birol I.
[bioRxiv 2024.03.26.586646; doi: ](https://doi.org/10.1101/2024.03.26.586646)
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
