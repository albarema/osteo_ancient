# conda activate osteo
# --------------------------------------------------------------------------------
configfile: 'config.yaml'
## --------------------------------------------------------------------------------
CHROMS = range(1, 23)
PANS=['inds', 'pops']

rule all:
    input: expand("paneldir/temp2_vcf_allchr_{panel}.acf",panel=PANS)


rule get_acf:
    input:
        vcf="vcf/{chrom}.trondheim.gbr.hg19.vcf.gz",
        epofile=config['epo'],
        faifile=config['fai'],
    output:
        tmp1="tmpDir/temp_vcf_chr{chrom}.acf",
    
    shell:
        """
        glactools vcfm2acf --onlyGT --epo {input.epofile} --fai {input.faifile} <(bcftools view {input.vcf}) > {output.tmp1}
        """
		
rule get_panel_acf:
    input:
        tmp1="tmpDir/temp_vcf_chr{chrom}.acf",
	    panelfile="/projects/mjolnir1/people/gsd818/osteoProject/{panel}.gbr.trondheim.txt"
    output:
	    tmp2=temp("tmpDir/temp2_vcf_chr{chrom}_{panel}.acf")
    shell:
        """
        glactools meld -f {input.panelfile} {input.tmp1} > {output.tmp2}
        """

rule merge_galact:
    input:
        tmp2=expand("tmpDir/temp2_vcf_chr{chrom}_{panel}.acf", chrom=CHROMS,allow_missing=True)
    output:
        acftp=temp("tmpDir/temp2_vcf_allchr_{panel}.acf"),
        popfile="paneldir/temp2_vcf_allchr_{panel}.acf"
    shell:
        """
        glactools cat {input.tmp2} > {output.acftp}
        cat <(glactools view -h {output.acftp} | head -1) <(glactools view {output.acftp}| sort -k1,1 -k2,2g) | bgzip -c > {output.popfile}
        tabix -s 1 -b 2 -e 2 {output.popfile}
        """