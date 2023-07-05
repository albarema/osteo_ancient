
configfile: 'config.yaml'
import pandas as pd
## --------------------------------------------------------------------------------
PHENOS = pd.read_table(config['ukb_traits'])['data_field']

rule all:
    input: 
        "plink/allchr.trondheim.gbr.hg19.qc.fam",
        expand("PRSice_Results/{pheno}.allchr.trondheim.gbr.hg19.log", pheno=PHENOS)

rule savefam:
    input:
        "plink/allchr.trondheim.gbr.hg19.fam"
    output:
        "plink/allchr.trondheim.gbr.hg19.raw.fam"
    shell:
        "cp {input} {output}"

rule get_fam:
    input:
        fam = "plink/allchr.trondheim.gbr.hg19.raw.fam",
        kgp="metadata/ukb_info_all.tsv",
        meta="Trondheim_SummaryTable.tsv"
    params:
        pre="plink/allchr.trondheim.gbr.hg19"
    output:
        "plink/allchr.trondheim.gbr.hg19.fam",
    shell:
        "Rscript scripts/get_fam_complete.R --fam {input.fam} --meta {input.meta} --ukb {input.kgp} --out {output}"

rule filter_plink:
    input:
        vcf="plink/allchr.trondheim.gbr.hg19.bed",
        fam2 = "plink/allchr.trondheim.gbr.hg19.fam",
    output:
        "plink/allchr.trondheim.gbr.hg19.qc.fam",
    params:
        out="plink/allchr.trondheim.gbr.hg19"
    shell:
        """
        plink2 --bfile {params.out} \
        --maf 0.05 \
        --mind 0.1 \
        --geno 0.1 \
        --hwe 1e-6 \
        --make-just-bim \
        --make-just-fam \
        --out {params.out}.qc
        """

rule pre_get_prs:
    """
    Run this to filter snsps, no --extract flag so that it creates filename.valid file and then using that (contains filtered snps)
    """
    input:
        vcf="plink/allchr.trondheim.gbr.hg19.bed",
        qc="plink/allchr.trondheim.gbr.hg19.qc.fam",
        sumstats="ukbb/candidates/inds-{pheno}.prsice.assoc",
    params: 
        Ppath="/projects/mjolnir1/people/gsd818/software/PRSice",
        out="allchr.trondheim.gbr.hg19"
    threads: 2
    conda: "/projects/mjolnir1/people/gsd818/osteoProject/environment.yaml"
    output:
        "PRSice_Results/{pheno}.allchr.trondheim.gbr.hg19.log"
    log: "logs/pre_PRSice/{pheno}.txt"
    shell:
        """
        Rscript {params.Ppath}/PRSice.R --dir . \
        --prsice {params.Ppath}/PRSice_linux \
        --base {input.sumstats} \
        --target plink/{params.out} \
        --keep plink/{params.out}.qc.fam \
        --no-default \
        --A1 ALT \
        --num-auto 22 \
        --lower 5e-08 \
        --thread {threads} \
        --stat ALTEFFECT \
        --beta \
        --pvalue PVAL \
        --snp SNPID \
        --print-snp \
        --out PRSice_Results/{wildcards.pheno}.{params.out} 2> {log}
        """