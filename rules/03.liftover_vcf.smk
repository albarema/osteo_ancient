# conda activate osteo
# --------------------------------------------------------------------------------
configfile: 'config.yaml'
## --------------------------------------------------------------------------------
import pandas as pd

## --------------------------------------------------------------------------------
CHROMS = range(1, 23)

rule all:
  input: 
    "plink/allchr.trondheim.gbr.hg19.bed",
    
# rule lift_hg19:
#   input:
#     vcf="glimpse_merge/{chrom}.trondheim.gbr.vcf.gz",
#     chain="/projects/mjolnir1/people/gsd818/ncbi_liftover/hg38ToHg19.over.chain.gz",
#     ref= config['ref_hg19']
#   output:
#     vcf=temp("vcf/{chrom}.trondheim.gbr.hg19.lo.vcf.gz"),
#     rej=temp("vcf/{chrom}.trondheim.gbr.hg19.rejected.vcf.gz")
#   threads: 12
#   params:
#     picard="/opt/software/picard/2.27.5/picard.jar"
#   shell:
#     """
#     java -Xmx360G -XX:ParallelGCThreads={threads} -jar {params.picard} LiftoverVcf -I {input.vcf} -O {output.vcf} -REJECT {output.rej} -CHAIN {input.chain} -R {input.ref}
#     """

# rule final_hg19:
#   input:
#     vcf="vcf/{chrom}.trondheim.gbr.hg19.lo.vcf.gz",
#   output:
#     vcf="vcf/{chrom}.trondheim.gbr.hg19.vcf.gz",
#   shell:
#     """
#     bcftools view -h {input.vcf} | bgzip -c > {output.vcf}
#     bcftools view -H {input.vcf} | perl -p -e 's/chr//' | awk '$1 == {wildcards.chrom}' | bgzip -c >> {output.vcf}
#     bcftools index -t {output.vcf}
#     """

# rule one_file:
#   input:
#     expand("vcf/{chrom}.trondheim.gbr.hg19.vcf.gz", chrom=CHROMS, allow_missing=True)
#   output:
#     "vcf/allchr.trondheim.gbr.hg19.vcf.gz"
#   shell:
#     "bcftools concat -Oz --threads {threads} {input} > {output}; "
#     "bcftools index -t {output}"

rule get_plink:
  input:
    "vcf/allchr.trondheim.gbr.hg19.vcf.gz"
  params:
    out="plink/allchr.trondheim.gbr.hg19"
  output:
    "plink/allchr.trondheim.gbr.hg19.bed"
  threads: 12
  shell:
    """
    plink2 --vcf {input} --double-id --real-ref-alleles --make-bed --out {params.out}
    """
