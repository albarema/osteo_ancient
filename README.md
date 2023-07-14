# Patterns of bone density in the XXX Folkebibliotekstomten collection

Compute PRS in ancient samples using records for osteological data and data from the UK Biobank [UKBB](http://www.nealelab.is/uk-biobank). 

Check environmental.yaml to see which software you need to pre-install before running this pipeline.

Pre-processing and generation of files:
- 00.wget_summstats.smk: download summary statistics from the GWAS of interest
- 01.imputation.smk: perform imputation. This step is important when working with ancient DNA (usually samples have low coverage)
- 02.filerting_vcf.smk: filtering of the imputed vcf file (common good practices). Since we had access to a limited number of ancient samples, we merged our dataset with GBR from the 1000 Genomes Project.
- 03.liftover_vcf.smk: liftover vcf files from GRCh38 to GRCh37 (older version). This step is important so that all files share the same human assembly reference. In our case, the summary statistics are based on GRCh37 and that is why we performed the liftover. 
- 04.vcf2acf.smk: convert vcf to population allele frequencies. This step is only needed if you are calculating population PRS (skip for individual PRS). It requires a file with the population/group information.
  
All steps until this point can be skipped if your target file has already been processed (Quality Control) and all files were produced using the same human assembly. 

- 05.pre_prs_ind.smk: Common step to both approaches. Get the association files in the correct form for the software. More details are under each of the sections.
  
This script produces a file for the steps to follow in both approaches:
- scripts/calc_alt.freqs.py: filters out low_confidence_variant and minor_AF < 0.01 and creates input files for PRS calculation. This file has to be different for every GWAS summary statistic that we test. Reasons: different number of column and column names for beta, MAF, p-value, alleles etc. In this step, we make sure there is an agreement with the polarization of the effect allele across GWAS (commonly ALT or Allele1). Important to know which human reference assembly has been used.

## Approach 1: PRSice 2
Workflow and more detailed information can be found here: [PRSice](https://choishingwan.github.io/PRSice/).

- 05.PRSice_step1.smk, pre-step that generates a clean SNPs file list (software detects duplicates and throws an error). The *output.valid* file is needed for step 2. 

- 05.PRSice_step2.smk, PRS calculates the PRS using osteological data (8 phenotypes) and different covariates are tested (sex vs. sex+fracture observations)

## Approach 2: LD-blocks Berisa et al.2014

During the pre-step, we generate the "candidate SNPs" associated with each of the traits under 2 different p-value thresholds (strict:5e-8 and lenient:1e-5). A file with the phenotypes that pass the tested p-value thresholds is also generated. We consider that a phenotype passes the cutoff if we found SNPs present in at least 10/1400 of the LD blocks (after p-value filtering!).

- scripts/calc_alt.freqs.py: filters (see above) and combines the GWAS with the VCF information by calculating allele frequencies across all individuals.
- scripts/partitionUKB_inds.py: generates trait-associated SNP candidates.
- scripts/get_pass_traits.py: table with phenotypes that passes p-value cutoff.
