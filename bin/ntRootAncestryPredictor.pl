#!/usr/bin/env perl

#AUTHOR
#   Rene Warren
#   rwarren at bcgsc.ca

#NAME
#   nteditAncestryPredictor.pl

#SYNOPSIS
#   ntedit-driven human super-population-level ancestry predictions using 1000 Genomes Project integrated variant call set

#DOCUMENTATION
#   Readme distributed with this software @ www.bcgsc.ca
#   http://www.bcgsc.ca/platform/bioinfo/software/ntedit
#   We hope this code is useful to you -- Please send comments & suggestions to rwarren * bcgsc.ca
#   If you use ntEdit, the ntEdit code or ideas, please cite our work

#LICENSE
#   ntEdit Copyright (c) 2018-now British Columbia Cancer Agency Branch.  All rights reserved.
#   ntEdit and companion code is released under the GNU General Public License v3

use strict;
my $dw = 5000000;
if($#ARGV<0){
   die "Usage: $0 < *variants.vcf > < window size default: $dw >\n";
}

my $f = $ARGV[0];
$dw = $ARGV[1] if($ARGV[1]);

open(IN, $f) || die "can't read $f -- fatal.\n";

my $xr=0;
my $s;
my $y;
my $z;

print "Inferring ancestry using SNVs (single nucleotide variants)...\n\n";

while(<IN>){
	chomp;
	my @a=split(/\t/);
	my $max;
	my $maxpop;

	if(/_AF/){
		#print "$a[1]..$dw..";
		my $wn = int($a[1] / $dw);
		#print "$wn\n";
		$xr++;

		my @b=split(/\;/,$a[7]);
		my @e=split(/\=/,$b[3]);
		my @c=($b[4],$b[5],$b[6],$b[7],$b[8]);

      		foreach my $el(@c){
         		my @d=split(/\=/,$el);
			my $pop=$1 if($d[0]=~/(\S+)\_/);
         		$s->{$d[0]}{'sum'}+=$d[1];

			#chr  winnum   pop
			$z->{$a[0]}{$wn}{$pop}{'sum'}+=$d[1];
			$y->{$a[0]}{$wn}{'ct'}++;


         		if($d[1]){$s->{$d[0]}{'ct'}++;
				$z->{$a[0]}{$wn}{$pop}{'nzct'}++;
				#LG      start   end     value   color
				if($a[1]>$max){
					$max=$a[1];
					$maxpop=$pop;
				}
			}else{
				$d[1]=1;
			}
         		if(! defined $s->{$d[0]}{'eval'}){$s->{$d[0]}{'eval'}=1;}
         		$s->{$d[0]}{'eval'} *= $d[1];
		}
   	}
}

###calculate metric per window
my $top;
my $total;

foreach my $el(sort {$a<=>$b} keys %$z){
	my $wnl=$z->{$el};
	foreach my $wnum(sort {$a<=>$b} keys %$wnl){
		my $pl = $wnl->{$wnum};
		my $winmax;
		my $winpop;
		print "WARNING: chr$el window$wnum has $y->{$el}{$wnum}{'ct'} only total SNVs -- you may need to increase the window size (currently set at $dw)\n" if($y->{$el}{$wnum}{'ct'}<100);
		foreach my $pp(keys %$pl){
			my $rate = $pl->{$pp}{'sum'}/$y->{$el}{$wnum}{'ct'};
			#my $metric = $pl->{$pp}{'nzct'} * $rate;
			my $metric = ($pl->{$pp}{'nzct'}/$y->{$el}{$wnum}{'ct'}) * $rate;
			if($metric>$winmax){
				$winmax = $metric;
				$winpop = $pp;			
			}
		}
		$top->{$winpop} += $dw;
		$total += $dw;
	}
}

close IN;

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

my $out = $f . "_ancestry-predictions1.tsv";
open(OUT,">$out") || die "Can't write to $out -- fatal.\n";

my $header_str = "Rank\tPopulation\tTotal_SNV_count\tPopulation_non-zero-Allele-freq_SNV_count\tAncestry_inference_score\tAncestry_fraction_window$dw-bp\n";
print OUT $header_str;

my $rank=0;
foreach my $k(sort {$s->{$b}{'prob'}<=>$s->{$a}{'prob'}} keys %$s){
	$rank++;
	my $population=$1 if($k=~/(\S+)\_/);
	my $percent = $top->{$population}/$total *100;
	printf OUT "$rank\t$population\t$xr\t$s->{$k}{'ct'}\t%.4f\t%.2f%%\n", ($s->{$k}{'prob'}, $percent);
}

print "\nAncestry_inference_score: Average SNV allele frequency * rate of SNVs with non-zero allele frequency\n";
print "\nAncestry predictions available in:\n$out\n\n";

exit(0);