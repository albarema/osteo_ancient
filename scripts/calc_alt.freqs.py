   #!/usr/bin/python

import pysam,gzip,csv
from optparse import OptionParser
import subprocess
# python scripts/weigthedES_byGP.py -a paneldir/

parser = OptionParser("$prog [options]")
parser.add_option("-v", "--vcffile", dest="vcffile", help="Input VCF file", default=None, type="string"),
parser.add_option("-o", "--outfile", dest="outfile", help="Output file (def None)", default=None, type="string")
parser.add_option("-p", "--outfile2", dest="outfile2", help="Output file 2 for prsice(def None)", default=None, type="string")
parser.add_option("-g", "--gwasfile", dest="gwasfile", help="GWAS file", default=None, type="string")
(options,args) = parser.parse_args()

# Read vcf and ancestral state files
vcffile = pysam.Tabixfile(options.vcffile,mode='r')

# Open output file
outfile = open(options.outfile,"w")
outfile2 = open(options.outfile2,"w")

# Record population panels
for line in vcffile.header:
    if "#CHROM" in line:
        popordered = line.split("\t")[9:]

# Print header
header = "#CHROM\tPOS\tSNPID\tREF\tALT\tALTEFFECT\tSE\tPVAL\t"
outfile2.write(''.join(header) + '\n')

header += "\t".join(popordered)
outfile.write(''.join(header) + '\n')


# Read files
with gzip.open(options.gwasfile, mode="rt") as tsvfile:
    reader = csv.DictReader(tsvfile, dialect='excel-tab')
    for row in reader:
        info = row['variant']
        infofields = info.strip("\n").split(":")
        chrom = infofields[0]
        pos = infofields[1]
        gref = infofields[2]
        galt = infofields[3]
        effect = row['beta']
        se = row['se']
        pval = row['pval']
        mAF = float(row['minor_AF'])
        lowcon = row['low_confidence_variant']
        if lowcon == 'true' or  mAF <= 0.01: continue   
        prevpos = int(pos) - 1
        try:
            vcfline = vcffile.fetch(str(chrom), int(prevpos), int(pos))
        except:
            continue
        nelem="NA"
        for sub in vcfline:
            nelem = sub
            if nelem == "NA":
                continue
            fields = nelem.strip("\n").split("\t")
            snpid = fields[2]
            ref = fields[3]
            alt = fields[4]
            freqs = []
            for x in fields[9:]:
                gt = x.split(":")[0]
                altfreq = (float(gt.split("|")[0]) + float(gt.split("|")[1]))/2
                freqs.append(str(altfreq))
            finalvec = [chrom, str(pos), snpid, ref, alt, str(effect), str(se), str(pval)] + freqs
            finalvecS = [chrom, str(pos), snpid, ref, alt, str(effect), str(se), str(pval)]

            outfile.write("\t".join(finalvec) + '\n')
            outfile2.write("\t".join(finalvecS) + '\n')

outfile.close()
outfile2.close()





