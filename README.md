# Patterns of bone density in the XXX Folkebibliotekstomten collection

Compute PRS in ancient samples using records for osteological data 

## Approach 1: PRSice 2
Workflow and more detailed information can be found here:[Link Text](https://choishingwan.github.io/PRSice/).

- 05.pre_prs_ind.smk: Get the association files in the correct form for the software

- 05.PRSice_step1.smk, pre-step that generates a clean snps file list (software detects duplicates and throws an error). The *output.valid* file is needed for step 2. 

- 05.PRSice_step2.smk, PRS calculates the PRS using osteological data (8 phenotypes) and different covariates are tested (sex vs. sex+fracture observations)

## Approach 2: LD-blocks Berisa et al.2014
