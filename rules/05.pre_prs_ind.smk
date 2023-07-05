# conda activate osteo
import pandas as pd
# --------------------------------------------------------------------------------
configfile: 'config.yaml'
## --------------------------------------------------------------------------------
CHROMS = range(1, 23)
PANS=['inds', 'pops']
PHENOS = pd.read_table(config['ukb_traits'])['data_field']

rule all:
    input: 
        #expand("ukbb/candidates/{level}-{pheno}-candidates-gw.tsv",level=['inds'], pheno=PHENOS),
        #expand("ukbb/candidates/{level}-{pheno}.prsice.assoc",level=['inds'], pheno=PHENOS),
        "data/ukbb/traits_OfInterest_pass.txt"



rule get_file:
    input:
        vcf="vcf/allchr.trondheim.gbr.hg19.vcf.gz",
        sumstats=config['uk_sums']
    output:
        tsv=temp("ukbb/candidates/{level}-{pheno}.tsv"),
        prsice="ukbb/candidates/{level}-{pheno}.prsice.assoc"
    shell:
        """
        python scripts/calc_alt.freqs.py -v {input.vcf} -g {input.sumstats} -o {output.tsv} -p {output.prsice}
        """

rule final_input:
    input:
        "ukbb/candidates/{level}-{pheno}.tsv"
    output:
        "ukbb/candidates/{level}-{pheno}.tsv.gz"
    shell:
        """
        cat <(head -1 {input}) <(tail -n+2 {input} | sort -k1,1 -k2,2g) | bgzip -c > {output}
        tabix -s 1 -b 2 -e 2 {output}
        """

rule get_can:
    input:
        wes="ukbb/candidates/{level}-{pheno}.tsv.gz",
        lbd=config['ldb']
    output:
        can="ukbb/candidates/{level}-{pheno}-candidates-{pvals}.tsv",
    params:
        pvals= lambda wildcards: 1e-5 if wildcards.pvals == "lenient" else 5e-8
    shell:
        "python scripts/partitionUKB_inds.py"
        " -i {input.wes}"
        " -b {input.lbd}"
        " -o {output.can}"
        " -p {params.pvals}"


rule get_pass:
    input:
        can=expand("ukbb/candidates/{level}-{pheno}-candidates-{pvals}.tsv",pvals=['gw', 'lenient'],level=['inds'], pheno=PHENOS)
    output:
        "data/ukbb/traits_OfInterest_pass.txt"
    shell:
        "python scripts/get_pass_traits.py -i '{input}' -o {output}"
