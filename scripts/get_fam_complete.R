
#--------------------------------------------------------------------------------
# Libraries
#--------------------------------------------------------------------------------
# Libraries
quiet <- function(x) { suppressMessages(suppressWarnings(x)) }
quiet(library(tidyverse))
quiet(library(optparse))

##----------------------------------------------------------------------------------------------
# Get command-line arguments

option_list = list(
  make_option(c("-u", "--ukb"), type="character", default=NULL, help="pass traits and pvals"),
  make_option(c("-f", "--fam"), type="character", default=NULL, help="path to fam plink"),
  make_option(c("-m", "--meta"), type="character", default=NULL, help="meta info for ancient samples"),
  make_option(c("-o", "--out"), type="character", default="output.txt", help="Output file name")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
##----------------------------------------------------------------------------------------------
full = opt$meta
fam = opt$fam
measurem = opt$mesus
outfile = opt$out
genproj = opt$ukb 
##----------------------------------------------------------------------------------------------
# genproj="metadata/ukb_info_all.tsv"
#full="Trondheim_SummaryTable.tsv"
#sam = read.table("allchr.trondheim.gbr.hg19.fam", header=F) %>% as_tibble()
sam =  read.table(fam, header=F) %>% as_tibble()
colnames(sam) = c('FID','IID','IDF','IDM', 'sex','pheno')
KGP= read_tsv(genproj, show_col_types = FALSE)
fullin = read_tsv(full,show_col_types = FALSE)

sam$sex <- fullin$sex[match(sam$FID, fullin$Sample_name)]
sam[which(is.na(sam$sex)),]$sex <- KGP$gender[match(sam[which(is.na(sam$sex)),]$FID, KGP$sample)]

sam[sam$sex %in% c("male","XY"),]$sex <- "1"
sam[sam$sex %in% c("female","XX"),]$sex <- "2"
sam[!sam$sex %in% c("1","2"),]$sex <- "0"
sam$sex = as.numeric(sam$sex)

write.table(sam, outfile,sep=" ", col.names=FALSE,row.names=FALSE, quote=FALSE)#Sex code ('1' = male, '2' = female, '0' = unknown)