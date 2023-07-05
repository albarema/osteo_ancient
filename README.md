# Patterns of bone density in the XXX Folkebibliotekstomten collection

Compute PRS in ancient samples using records for osteological data 
- Approach 1: PRSice 2

Get the association files in the correct fromat for software

Pre-PRS, step 1 generates a clean snps file list (software detects duplicates and throws an error). The output.valid file is needed for step 2. 
PRS, calculates the PRS using osteolofical data (8 phenotypes) and different covariates are tested (sex vs. sex+fracture observations)

- Approach 2: LD-blocks Berisa et al.2014
