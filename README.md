# Patterns of bone density in the XXX Folkebibliotekstomten collection

Compute PRS in ancient samples using records for osteological data 

- 05.pre_prs_ind.smk: Common step to get the association files in the correct form for the software. More details are under each of the sections. 
  
## Approach 1: PRSice 2
Workflow and more detailed information can be found here:[Link Text](https://choishingwan.github.io/PRSice/).

- 05.PRSice_step1.smk, pre-step that generates a clean SNPs file list (software detects duplicates and throws an error). The *output.valid* file is needed for step 2. 

- 05.PRSice_step2.smk, PRS calculates the PRS using osteological data (8 phenotypes) and different covariates are tested (sex vs. sex+fracture observations)

## Approach 2: LD-blocks Berisa et al.2014

During the pre-step, we generate the "candidate snps" associated with each of the traits under 2 different p-value thresholds (strict:5e-8 and lenient:1e-5). A file with the phenotypes that pass the tested p-value thresholds is also generated. We consider that a phenotype passes the cutoff if we found SNPs present in at least 10/1400 of the LD blocks (after p-value filtering!).
