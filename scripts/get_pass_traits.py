
from optparse import OptionParser

parser = OptionParser("$prog [options]")
parser.add_option("-i", "--infiles", dest="infiles", help="Input GWAS+freq file", default=None, type="string")
parser.add_option("-o", "--outfile", dest="outfile", help="Output file", default=None, type="string")
(options,args) = parser.parse_args()

fout= open(options.outfile , mode="w")
header="ukbb_pass\tpvalue"
fout.write(''.join(header) + '\n')


filesInput = options.infiles.split(" ")
print(filesInput)
for fil in filesInput:
    tsv=open(fil, "r")
    if len(tsv.readlines()) > 10:
        pheno=fil.split("-")[1]
        pvals=fil.split("-")[3].split(".")[0]
        fout.write(str(pheno)+ "\t"+ str(pvals) + '\n')
    else: continue
