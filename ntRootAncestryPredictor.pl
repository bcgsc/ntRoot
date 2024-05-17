#!/usr/bin/env perl

#AUTHORS
#   Rene Warren
#   Lauren Coombe

#NAME
#   ntRootAncestryPredictor.pl

#SYNOPSIS
#   ntRoot : ntedit-powered human super-population-level ancestry predictions using 1000 Genomes Project integrated variant call set

#DOCUMENTATION
#   Readme distributed with this software @ www.bcgsc.ca
#   http://www.bcgsc.ca/platform/bioinfo/software/ntroot
#   http://www.bcgsc.ca/platform/bioinfo/software/ntedit
#   We hope this code is useful to you -- Please send comments & suggestions to rwarren * bcgsc.ca
#   If you use ntRoot, ntEdit, the ntEdit code or ideas, please cite our work

#LICENSE
#   ntRoot Copyright (c) 2024-now British Columbia Cancer Agency Branch.  All rights reserved.
#   ntRoot and companion code is released under the GNU General Public License v3

use strict;
use Getopt::Std;
use vars qw($opt_f $opt_t $opt_v $opt_r $opt_i);

my $dw = 5000000;
my $verbose = 0;
my $tile_resolution = 0;
my $fai = "";

getopts('f:t:v:r:i:');

sub usage_page {
	print "\nUsage: $0 -f *variants.vcf [-t TILE_SIZE] [-v VERBOSITY] [-r TILE_OUTPUT] [-i FAI]\n";
	print "\t-f\tVariants VCF file\n";
	print "\t-t\tTile size [$dw bp]\n";
	print "\t-v\tVerbose mode - 0 (False) or 1 (True) [0]\n";
	print "\t-r\tOutput ancestry inferences per tile - 0 (False) or 1 (True) [0]\n";
	print "\t-i\tReference FAI file (Only required when -r specified)\n\n";
}


if (!$opt_f || ($opt_r && !$opt_i)) {
	usage_page();
	exit(1);
}

my $f = $opt_f;
$dw = $opt_t if ($opt_t);
$verbose = $opt_v if ($opt_v);
$tile_resolution = $opt_r if ($opt_r);
$fai = $opt_i if ($opt_r && $opt_i);
	
	
my $chr;
# Read in the FAI file for chromosome lengths
if ($tile_resolution) {
	open(IN,$fai) || die "Can't read $fai --fatal (is the file in your working directory?)\n";
	while(<IN>){
	chomp;
	my @a=split(/\t/);
	$chr->{$a[0]}=$a[1];
	}
}


open(IN, $f) || die "can't read $f -- fatal.\n";

my $xr=0;
my $s;
my $y;
my $z;
my $populations;

print "Inferring ancestry using SNVs (single nucleotide variants)...\n\n";

while(<IN>){
	chomp;
	my @a=split(/\t/);
	my $max;
	my $maxpop;

	if(/_AF/){
		my $wn = int($a[1] / $dw);
		$xr++;

                my @alleles = split(/\^/,$a[7]);

                #21      5097811 .       G       A       .       PASS    AD=11^AC=115;AN=5096;DP=12758;AF=0.02;EAS_AF=0.03;EUR_AF=0.01;AFR_AF=0.03;AMR_AF=0.03;SAS_AF=0.03;VT=SNP;NS=2548        GT      1/1

                foreach my $allele(@alleles){

			my @b=split(/\;/,$allele);

			foreach my $el(@b){
				my @d=split(/\=/,$el);
				if($d[0]=~/(\S+)\_AF/){
					my $pop=$1;
					my @alleles = split(/,/,$d[1]);
					foreach my $allele(@alleles){
						if ($allele !~ /\d+/) {
							next;
						}
						if (! defined $populations->{$pop}) {
							$populations->{$pop} = 1;
						}
						$s->{$d[0]}{'sum'}+=$allele;

						#chr  winnum   pop
						$z->{$a[0]}{$wn}{$pop}{'sum'}+=$allele;
						$y->{$a[0]}{$wn}{'ct'}++;


						if($allele){
							$s->{$d[0]}{'ct'}++;
							$z->{$a[0]}{$wn}{$pop}{'nzct'}++;
							if($a[1]>$max){
								$max=$a[1];
								$maxpop=$pop;
							}
						} else{
							$allele=1;
						}
					}
				}
			}
   		}
	}
}
###calculate metric per tile
my $top;
my $total;
my @ordered_populations = sort keys %$populations;

if ($tile_resolution) {
	my $best = $f . "_ancestry-predictions-tile-resolution_tile$dw.tsv";
	open(BEST,">$best") || die "Can't write to $best -- fatal.\n";
	print BEST "chrom\tstart\tend\tancestry_prediction";
	foreach my $population (@ordered_populations) {
		print BEST "\t$population-score";
	}
	print BEST "\n";
}

foreach my $el(sort {$a<=>$b} keys %$z){
	my $wnl=$z->{$el};
	foreach my $wnum(sort {$a<=>$b} keys %$wnl){
		my $pl = $wnl->{$wnum};
		my $winmax;
		my $winpop;
		my $window_population_metric;
		print "WARNING: chr$el tile$wnum has $y->{$el}{$wnum}{'ct'} only total SNVs -- you may need to increase the tile size (currently set at $dw)\n" if($y->{$el}{$wnum}{'ct'}<100);
		foreach my $pp(keys %$pl){
			my $rate = $pl->{$pp}{'sum'}/$y->{$el}{$wnum}{'ct'};
			my $metric = ($pl->{$pp}{'nzct'}/$y->{$el}{$wnum}{'ct'}) * $rate;
			$window_population_metric->{$pp} = $metric;
			if($metric>$winmax){
				$winmax = $metric;
				$winpop = $pp;
			}
		}
		$top->{$winpop} += $dw;
		$total += $dw;
		if ($tile_resolution) {
			my $chunk = $wnum * $dw;
			my $start = $chunk + 1;
			my $end = $chunk + $dw;
			$end = $chr->{$el} if($end>$chr->{$el});
			print BEST "$el\t$start\t$end\t$winpop";
			foreach my $population (@ordered_populations) {
				printf BEST "\t%.4f", ($window_population_metric->{$population});
			}
			print BEST "\n";
		}

	}
}

close IN;
if ($tile_resolution) {
	close BEST;
}

if(! $xr){
	print "\n! There are no cross-referenced SNV in $f; no ancestry predictions can be reported !\n\n\tDid you:\n\t1) Run ntedit with the correct and properly-formatted human genome input\n\t\te.g., chromosome 14 should be: >14\n\t\te.g., -f GRCh38.fa\n\n\t2) Supply the 1000 Genomes Project integrated variant callset vcf to ntedit with -l\n\t\te.g., ntedit -r ERR3242189_k55.bf -f GRCh38.fa -t 48 -Y 0.55 -s 1 -l 1000GP_integrated_snv_v2a_27022019.GRCh38.phased_gt1.vcf.gz\n\n";
	exit(1);
}


#calculate/incorporate metrics
foreach my $k(keys %$s){
	my $p = $s->{$k}{'sum'}/$xr;
	my $c = $s->{$k}{'sum'}/$s->{$k}{'ct'};
	my $nzr = $s->{$k}{'ct'}/$xr;
	$s->{$k}{'prob'} = $p*$nzr;
	$s->{$k}{'fract'} = $p*$s->{$k}{'ct'};
}

#output predictions

my $out = $f . "_ancestry-predictions_tile$dw.tsv";
open(OUT,">$out") || die "Can't write to $out -- fatal.\n";

my $header_str = "GAI Super-population\tLAI fraction (tile:$dw bp)\tGAI score\tTotal SNV count\tNon-zero AF SNV count";
if ($verbose) {
	$header_str = $header_str . "\tSumAF\tAvgAF\tnzAvgAF\tnzSNVrate\tAvgAF * nzAF_SNV_count\n";
} else {
	$header_str = $header_str . "\n";
}

print OUT $header_str;

my $rank=0;
foreach my $population(sort {$top->{$b}<=>$top->{$a}} keys %$top){
	$rank++;
	my $k = $population . "_AF";
	my $percent = $top->{$population}/$total *100;
	printf OUT "$population\t%.2f%%\t%.4f\t$xr\t$s->{$k}{'ct'}", ($percent, $s->{$k}{'prob'});
	if ($verbose) {
		my $p = $s->{$k}{'sum'}/$xr;
		my $c=$s->{$k}{'sum'}/$s->{$k}{'ct'};
		my $nzr=$s->{$k}{'ct'}/$xr;
		printf OUT "\t%.2f\t%.4f\t%.4f\t%.4f\t%.2f\n", ($s->{$k}{'sum'}, $p, $c, $nzr, $s->{$k}{'fract'});
	} else {
		printf OUT "\n";
	}
}

print "\nGAI score: Average SNV allele frequency * rate of SNVs with non-zero allele frequency\n";
print "Populations are ranked based on the LAI fraction\n";
print "\nAbbreviations:\n\tAF: Allele Frequency";
if ($verbose) {
	print "\n\tnz: Non-zero\n";
}
print "\n\nAncestry predictions available in:\n$out\n\n";

exit(0);
