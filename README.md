# ntRoot

Ancestry inference from genomic data

## Credit
Written by Rene Warren

## Installation

Installing ntRoot from the source code:
```
git clone --recurse-submodules https://github.com/bcgsc/ntRoot.git
cd ntRoot
meson setup build --prefix=/path/to/install/directory
cd build
ninja install
```
ntRoot and all required scripts will be installed to: /path/to/install/directory

### Dependencies
- python 3.9+
- perl
- [meson](https://mesonbuild.com/)
- [ninja](https://ninja-build.org/)
- [snakemake](https://snakemake.readthedocs.io/en/stable/)

## Usage
```
usage: ntRoot [-h] --draft DRAFT [--reads READS] [--genome GENOME [GENOME ...]] [-l L] -k K [--bloomType {bf,cbf}] [--window WINDOW] [--cutoff CUTOFF]
                  [--solid] [-t T] [-z Z] [-y Y] [-j J] [-X X] [-Y Y] [-p P] [-q Q] [-v] [-V] [-n] [-f]
ntRoot: Ancestry inference from genomic data

optional arguments:
  -h, --help            show this help message and exit
  --draft DRAFT         Draft genome assembly (FASTA, Multi-FASTA, and/or gzipped compatible)
  --reads READS         Prefix of input reads file(s) for detecting SNVs.All files in the working directory with the specified prefix will be used.(fastq, fasta, gz, bz, zip)
  --genome GENOME [GENOME ...]
                        Genome assembly file(s) for detecting SNVs on --draft
  -l L                  input VCF file with annotated variants (e.g., clinvar.vcf)
  -k K                  k-mer size
  --tile TILE       Tile size for ancestry fraction inference (bp) [default=5000000]
  -t T                  Number of threads [default=4]
  -z Z                  Minimum contig length [default=100]
  -j J                  controls size of k-mer subset. When checking subset of k-mers, check every jth k-mer[default=3]
  -Y Y                  Ratio of number of k-mers in the k subset that should be present to accept an edit (higher=stringent) [default=0.55]
  -v, --verbose                    Verbose mode [default=False]
  -V, --version         show program's version number and exit
  -n, --dry-run         Print out the commands that will be executed
  -f, --force           Run all ntRoot steps, regardless of existing output files

Note: please specify --reads OR --genome (not both)
If you have any questions about ntRoot, please open an issue at https://github.com/bcgsc/ntRoot
```
