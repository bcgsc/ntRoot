#!/bin/bash

echo "Running ntRoot demo..."
echo "Please ensure that ntRoot is on your PATH"

set -eux -o pipefail

echo "Running ntroots reads demo..."
wget https://www.bcgsc.ca/downloads/btl/ntroot/reads_demo/ERR3239334.chr21_1.fq.gz
wget https://www.bcgsc.ca/downloads/btl/ntroot/reads_demo/ERR3239334.chr21_2.fq.gz

ntroot --draft chr21.fa --reads ERR3239334.chr21_ -k 55 -l pop-spec-snp_chr21.vcf.gz

prediction=$(cat ERR3239334.chr21__ntedit_k55_variants.vcf_ancestry-predictions_tile5000000.tsv | awk '{print $1}' |head -n 2 |tail -n 1)

if [ ${pred} == "EUR" ]; then
	echo "ntRoot reads test successful!"
else 
	echo "ntRoot reads test failed.. Please check your installation."
	exit 1
fi