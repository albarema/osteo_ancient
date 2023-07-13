#!/usr/bin/env python3
configfile: 'config.yaml'
#-----------------------------------------------------------------------------------------------

import pandas as pd

#-----------------------------------------------------------------------------------------------
SEX="both_sexes|female|male"
PHENOS = pd.read_table(config['ukb_traits'])['data_field']
#-----------------------------------------------------------------------------------------------
rule all:
	input:
		expand("data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz", pheno=PHENOS, sex="both_sexes"),

rule ukbb_nealelab_gwas_md5:
    """
    Fetch the md5sum for the Per-phenotype file
    """
    input:
        tsv=config['ukb_man'],
    output:
        md5="data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz.md5",
    params:
        bgz="data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz",
    shell:
        """
        awk -F'\\t' '$1=="{wildcards.pheno}" && $4=="{wildcards.sex}" {{print $9" {params.bgz}"}}' {input.tsv} | head -n1 > {output.md5} 
        """


rule ukbb_nealelab_gwas:
    """
    Download the NealeLab UKBB GWAS summary statistics for a specific phenotype
    see https://docs.google.com/spreadsheets/d/1kvPoupSzsSFBNSztMzl04xMoSC3Kcx3CrjVf4yBmESU/edit?ts=5b5f17db#gid=227859291
    """
    input:
        tsv=config['ukb_man'],
        md5="data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz.md5",
    output:
        bgz="data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz",
    shell:
        """awk -F'\\t' '$1=="{wildcards.pheno}" && $4=="{wildcards.sex}" {{print $7}}' {input.tsv} | head -n1 | """
        """xargs wget --quiet -O {output.bgz} && md5sum --status --check {input.md5}"""
    
# rule clean_sumstats:
#     """
#     Filter for maf and low-confident-variants - now implemented in calc_alt_freqs.py
#     """
#     input:
#         "data/ukbb/nealelab/{pheno}.gwas.imputed_v3.{sex}.tsv.bgz"
#     output:
#         "tmpDir/ukbb/{pheno}.gwas.imputed_v3.{sex}.tsv.gz"
#     shell:
#         """
#         Rscript scripts/ukb2_filter_LC.R -w {input} -o {output}
#         """

rule prep_liftover:
    """
    chrm is a int - might need chr before
    """
    input:
        "tmpDir/ukbb/{pheno}.gwas.imputed_v3.{sex}.tsv.gz"
    output:
        "tmpDir/ukbb/{pheno}.gwas.imputed_v3.{sex}.tsv.reorder.bgz"
    shell:
        """
        cat <(echo -e "#CHROM\tPOS\tID\tREF\tALT\tN\tBETA\tSE\tTSTAT\tPVAL") \
        <(zless {input} |tail -n +2 | \
        sed 's/\:/\t/' | sed 's/\:/\t/' | sed 's/\:/\t/' | sed '/X/d' | \
        awk '!seen[$1, $2]++'| awk '$11!="NaN"' | \
        awk '{{print $1,$2,$1":"$2,$3,$4,$8,$11,$12,$13,$14}}' | \
        sort -k2,2 -k3,3g) | bgzip -c > {output}
        """
