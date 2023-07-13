# conda activate osteo
# --------------------------------------------------------------------------------
configfile: 'config.yaml'
## --------------------------------------------------------------------------------
import pandas as pd

## --------------------------------------------------------------------------------
CHROMS = range(1, 23)

rule all:
  input: 
    expand("glimpse_merge/{chrom}.trondheim.gbr.vcf.gz", chrom=CHROMS),

rule vcf_4prsice:
  """
  FILTERS recommended in the paper for datsets with N<1000
  """
  input:
    vcf="glimpse/{chrom}.glimpse.vcf.gz"
  output:
    vcf="glimpse_filtered/{chrom}.glimpse.prsice.vcf.gz"
  threads: 4
  shell:
    """
    bcftools view -e 'INFO<=0.8' -m2 -M2 -v snps -Oz {input.vcf} > {output.vcf}; 
    bcftools index -t {output.vcf} 
    """

rule isec:
  input:
    vcf="glimpse_filtered/{chrom}.glimpse.prsice.vcf.gz",
    vcf_1kgp="/projects/mjolnir1/people/gsd818/1000genomes_2015_nature/vcf/chr{chrom}.1000g.freeze9.umich.GRCh38.snps.biallelic.pass.vcf.gz"
  output:
    vcf1=temp("tmpDir/{chrom}/0000.vcf.gz"),
    vcf2=temp("tmpDir/{chrom}/0001.vcf.gz")
  shell:
    """
    bcftools isec -n=2 -p tmpDir/{wildcards.chrom} {input.vcf} {input.vcf_1kgp} -Oz 
    """

rule merge_1k:
  input:
    vcf="tmpDir/{chrom}/0000.vcf.gz",
    vcf_1kgp="tmpDir/{chrom}/0001.vcf.gz"
  output:
    vcf=temp("tmpDir/{chrom}.trondheim.1kg.vcf.gz")
  shell:
    "bcftools merge -m snps {input.vcf} {input.vcf_1kgp} -Oz > {output.vcf} ; "
    "bcftools index -t {output.vcf}"

rule final_vcf:
  input:
    vcf="tmpDir/{chrom}.trondheim.1kg.vcf.gz",
  output:
    vcf="glimpse_merge/{chrom}.trondheim.1kg.vcf.gz"
  shell:
    "bcftools view -q 0.05:minor {input.vcf} -Oz > {output.vcf}; "
    "bcftools index -t {output.vcf}"
 
rule fil_samples:
  input:
    vcf="glimpse_merge/{chrom}.trondheim.1kg.vcf.gz",
    ids="gbr.trondheim.txt"
  output:
    vcf="glimpse_merge/{chrom}.trondheim.gbr.vcf.gz"
  shell:
    "bcftools view -S {input.ids} {input.vcf} -Oz > {output.vcf}; "
    "bcftools index -t {output.vcf}"

