
configfile: 'config.yaml'
import pandas as pd
## --------------------------------------------------------------------------------
PHENOS = pd.read_table(config['ukb_traits'])['data_field']

rule all:
    input: 
        expand("PRSice_Results/{pheno}.allchr.trondheim.gbr.hg19.summary", pheno=PHENOS)

rule get_covs:
    input:
        fam="plink/allchr.trondheim.gbr.hg19.qc.fam",
        phenos="plink/allchr.trondheim.gbr.hg19.pheno"
    output:
        "plink/allchr.tronheim.gbr.hg19.covs"
    shell:
        "Rscript scripts/get_cov_complete.r {input.fam} {input.phenos} {output}"

rule get_prs:
    """
    Run it twice, one without the --extract flag so that it creates filename.valid file and then using that (contains filtered snps)
    """
    input:
        vcf="plink/allchr.trondheim.gbr.hg19.bed",
        qc="plink/allchr.trondheim.gbr.hg19.qc.fam",
        sumstats="ukbb/candidates/inds-{pheno}.prsice.assoc",
        pheno = "plink/allchr.trondheim.gbr.hg19.pheno",
        valid = "logs/pre_PRSice/{pheno}.txt",
        covs="plink/allchr.tronheim.gbr.hg19.covs"
    params: 
        Ppath="/projects/mjolnir1/people/gsd818/software/PRSice",
        out="allchr.trondheim.gbr.hg19"
    threads: 2
    conda: "/projects/mjolnir1/people/gsd818/osteoProject/environment.yaml"
    output:
        "PRSice_Results/{pheno}.allchr.trondheim.gbr.hg19.summary"
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
        --pheno {input.pheno} \
        --pheno-col F90TOT_DEN,F90TRB_DEN,F90CRT_DEN,F95TOT_DEN,F95TRB_DEN,F95CRT_DEN,DXA_neck,DXA_ward \
        --thread {threads} \
        --stat ALTEFFECT \
        --beta \
        --extract PRSice_Results/{wildcards.pheno}.{params.out}.valid \
        --pvalue PVAL \
        --snp SNPID \
        --binary-target F,F,F,F,F,F,F,F \
#        --cov {input.covs} \
#        --cov-col sex \
        --out PRSice_Results/{wildcards.pheno}.{params.out}
        """
