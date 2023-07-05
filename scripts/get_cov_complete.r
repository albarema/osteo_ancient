#--------------------------------------------------------------------------------
# Libraries
quiet <- function(x) { suppressMessages(suppressWarnings(x)) }
quiet(library(tidyverse))
#--------------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
fam = args[1]
pheno= args[2]
outfile = args[3]

fams = read.table(fam, header=F) %>% as_tibble() 
colnames(fams) = c('FID','IID','IDF','IDM', 'sex','pheno')
phenos=read.table(pheno, header=T) %>% as_tibble() %>% select(FID,Fracture,OA,CO,LEH)

phenos = phenos %>% mutate_all(~ ifelse(. == "Yes", 1, .))
phenos = phenos %>% mutate_all(~ ifelse(. == "No", 2, .))
phenos = phenos %>% mutate_all(~ ifelse(is.na(.), -9, .))

fams = fams %>% select(FID, IID, sex) %>% mutate_all(~ ifelse(. == 0, -9, .))

df = merge(fams, phenos, by=1) %>% as_tibble() 
df <- df %>% mutate(across(-c(FID, IID), as.numeric))
write.table(df, outfile,sep=" ", col.names=TRUE,row.names=FALSE, quote=FALSE)