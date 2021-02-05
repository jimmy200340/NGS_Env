#optparse module
suppressPackageStartupMessages(library("optparse"))

#Initial args type
option_list <- list(
	make_option("--sample", type = "character", help = "sample name"),
	make_option("--annovar-snp", type = "character", help = "annovar multianno file path"),
	make_option("--intervar-snp", type = "character", help = "intervar multianno file path"),
	make_option("--snp-bp", type = "character", help = "snpsift_bp vcf file path"),
	make_option("--snp-cc", type = "character", help = "snpsift_cc vcf file path"),
	make_option("--snp-mf", type = "character", help = "snpsift_mf vcf file path"),
	make_option("--snp-kegg", type = "character", help = "snpsift_kegg vcf file path"),
	make_option("--snp-pid", type = "character", help = "snpsift_pid vcf file path"),
	make_option("--snp-biocarta", type = "character", help = "snpsift_biocarta vcf file path"),
	make_option("--snp-reactome", type = "character", help = "snpsift_reactome vcf file path"),
	make_option("--snp-vcf", type = "character", help = "snp vcf file path"),
	make_option("--annovar-indel", type = "character", help = "annovar multianno file path"),
	make_option("--intervar-indel", type = "character", help = "intervar multianno file path"),
	make_option("--indel-bp", type = "character", help = "snpsift_bp vcf file path"),
	make_option("--indel-cc", type = "character", help = "snpsift_cc vcf file path"),
	make_option("--indel-mf", type = "character", help = "snpsift_mf vcf file path"),
	make_option("--indel-kegg", type = "character", help = "snpsift_kegg vcf file path"),
	make_option("--indel-pid", type = "character", help = "snpsift_pid vcf file path"),
	make_option("--indel-biocarta", type = "character", help = "snpsift_biocarta vcf file path"),
	make_option("--indel-reactome", type = "character", help = "snpsift_reactome vcf file path"),
	make_option("--indel-vcf", type = "character", help = "indel vcf file path")
)

#parse args to code
opt <- parse_args(OptionParser(option_list=option_list))

#Stop if args are null
#if (is.null(opt$target_CB))
#{
  #print_help(opt)
 # stop("--target_CB required.", call.=FALSE)
#}

##snp
annovar <- read.delim(opt$'annovar-snp', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""))
if (length(which(annovar[,"Ref"]==0 | annovar[,"Alt"]==0))!=0) annovar <- annovar[-which(annovar[,"Ref"]==0 | annovar[,"Alt"]==0),] #去掉有0的位點
annovar <- tidyr::unite(annovar, index, c("Chr","Start","Ref","Alt"), sep=":", remove=F)

intervar <- read.delim(opt$'intervar-snp', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""))
if (length(which(intervar[,"Ref"]==0 | intervar[,"Alt"]==0))!=0) intervar <- intervar[-which(intervar[,"Ref"]==0 | intervar[,"Alt"]==0),] #去掉有0的位點
intervar[,"X.Chr"] <- paste("chr",intervar[,"X.Chr"], sep="")
intervar <- tidyr::unite(intervar, index, c("X.Chr","Start","Ref","Alt"), sep=":", remove=F)

#check duplicate
which(duplicated(annovar[,"index"]))
which(duplicated(intervar[,"index"]))

#rm duplicate
if (length(which(duplicated(intervar[,"index"])))!=0) intervar <- intervar[-which(duplicated(intervar[,"index"])),]

names(intervar)

select <- intervar[,c(1,31,32,33,34)]
combinded <- merge(x= annovar, y= intervar[,c(1,31,32,33,34)], by= "index", all.x = T)

names(combinded)


selectcombinded <- combinded[,c(1,2,3,23,5,6,133,134,7,8,9,10,11,13,16:53,54,56,57,59,60,62,63,65,66,68,69,71,72,74,93,
                                95,109,111,113,119,122,123,124,135,136,137,138,139,140,141)]
names(selectcombinded)
names(selectcombinded)[2] <- "CHROM"
names(selectcombinded)[3] <- "POS"
names(selectcombinded)[4] <- "ID"
names(selectcombinded)[5] <- "REF"
names(selectcombinded)[6] <- "ALT"
names(selectcombinded)[7] <- "QUAL"
names(selectcombinded)[8] <- "FILTER"
names(selectcombinded)[76] <- "INFO"
names(selectcombinded)[77] <- "FORMAT"
names(selectcombinded)[78] <- opt$sample
names(selectcombinded)

selectcombinded[,"Orpha"] <- gsub("<br>", " ", selectcombinded[,"Orpha"])
selectcombinded[,"Orpha"] <- gsub("or&nbsp;", " ", selectcombinded[,"Orpha"])
selectcombinded[,"Orpha"] <- gsub("~", " ", selectcombinded[,"Orpha"])


##GO_BP
bp <- read.delim(opt$'snp-bp', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
bp <- bp[grep("MSigDb",bp[,"INFO"]),]
bp[,"GO_BP"] <- sapply(strsplit(bp[,"INFO"], "MSigDb="), "[", 2)
bp <- tidyr::unite(bp, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
which(duplicated(bp[,"index"]))
#rm duplicate
if (length(which(duplicated(bp[,"index"])))!=0) bp <- bp[-which(duplicated(bp[,"index"])),]

##GO_CC
cc <- read.delim(opt$'snp-cc', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
cc <- cc[grep("MSigDb",cc[,"INFO"]),]
cc[,"GO_CC"] <- sapply(strsplit(cc[,"INFO"], "MSigDb="), "[", 2)
cc <- tidyr::unite(cc, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(cc[,"index"])))!=0) cc <- cc[-which(duplicated(cc[,"index"])),]

##GO_MF
mf <- read.delim(opt$'snp-mf', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
mf <- mf[grep("MSigDb",mf[,"INFO"]),]
mf[,"GO_MF"] <- sapply(strsplit(mf[,"INFO"], "MSigDb="), "[", 2)
mf <- tidyr::unite(mf, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(mf[,"index"])))!=0) mf <- mf[-which(duplicated(mf[,"index"])),]


##KEGG_PATHWAY
KEGG <- read.delim(opt$'snp-kegg', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
KEGG <- KEGG[grep("MSigDb",KEGG[,"INFO"]),]
KEGG[,"KEGG_PATHWAY"] <- sapply(strsplit(KEGG[,"INFO"], "MSigDb="), "[", 2)
KEGG <- tidyr::unite(KEGG, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(KEGG[,"index"])))!=0) KEGG <- KEGG[-which(duplicated(KEGG[,"index"])),]

##PID_PATHWAY
PID <- read.delim(opt$'snp-pid', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
PID <- PID[grep("MSigDb",PID[,"INFO"]),]
PID[,"PID_PATHWAY"] <- sapply(strsplit(PID[,"INFO"], "MSigDb="), "[", 2)
PID <- tidyr::unite(PID, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(PID[,"index"])))!=0) PID <- PID[-which(duplicated(PID[,"index"])),]

##BIOCARTA_PATHWAY
biocarta <- read.delim(opt$'snp-biocarta', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
biocarta <- biocarta[grep("MSigDb",biocarta[,"INFO"]),]
biocarta[,"BIOCARTA_PATHWAY"] <- sapply(strsplit(biocarta[,"INFO"], "MSigDb="), "[", 2)
biocarta <- tidyr::unite(biocarta, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(biocarta[,"index"])))!=0) biocarta <- biocarta[-which(duplicated(biocarta[,"index"])),]


##REACTOME_PATHWAY
reactome <- read.delim(opt$'snp-reactome', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
reactome <- reactome[grep("MSigDb",reactome[,"INFO"]),]
reactome[,"REACTOME_PATHWAY"] <- sapply(strsplit(reactome[,"INFO"], "MSigDb="), "[", 2)
reactome <- tidyr::unite(reactome, index, c("X.CHROM","POS","REF","ALT"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(reactome[,"index"])))!=0) reactome <- reactome[-which(duplicated(reactome[,"index"])),]



##combinded

combinded <- merge(x= selectcombinded, y= bp[,c("index", "GO_BP")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= cc[,c("index", "GO_CC")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= mf[,c("index", "GO_MF")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= KEGG[,c("index", "KEGG_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= PID[,c("index", "PID_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= biocarta[,c("index", "BIOCARTA_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= reactome[,c("index", "REACTOME_PATHWAY")], by= "index", all.x = T)

names(combinded)

names(combinded)[22] <- "avsnp150"
names(combinded)[29] <- "1000g2015aug_eas"
names(combinded)[30] <- "1000g2015aug_sas"
names(combinded)[31] <- "1000g2015aug_eur"
names(combinded)[32] <- "1000g2015aug_afr"
names(combinded)[33] <- "1000g2015aug_amr"
names(combinded)[34] <- "1000g2015aug_all"
names(combinded)[69] <- "GERP++_RS"

combinded <- combinded[,c(-1)]

write.table(combinded, opt$'snp-vcf', sep="\t",quote = F,na = ".",row.names = F) 


##indel
annovar <- read.delim(opt$'annovar-indel', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""))
if (length(which(annovar[,"Ref"]==0 | annovar[,"Alt"]==0))!=0) annovar <- annovar[-which(annovar[,"Ref"]==0 | annovar[,"Alt"]==0),] #去掉有0的位點
annovar <- tidyr::unite(annovar, index, c("Chr","Start","Ref","Alt"), sep=":", remove=F)

intervar <- read.delim(opt$'intervar-indel', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""))
if (length(which(intervar[,"Ref"]==0 | intervar[,"Alt"]==0))!=0) intervar <- intervar[-which(intervar[,"Ref"]==0 | intervar[,"Alt"]==0),] #去掉有0的位點
intervar[,"X.Chr"] <- paste("chr",intervar[,"X.Chr"], sep="")
intervar <- tidyr::unite(intervar, index, c("X.Chr","Start","Ref","Alt"), sep=":", remove=F)

#check duplicate
which(duplicated(annovar[,"index"]))
which(duplicated(intervar[,"index"]))

#rm duplicate
if (length(which(duplicated(intervar[,"index"])))!=0) intervar <- intervar[-which(duplicated(intervar[,"index"])),]

names(intervar)

select <- intervar[,c(1,31,32,33,34)]
combinded <- merge(x= annovar, y= intervar[,c(1,31,32,33,34)], by= "index", all.x = T)

names(combinded)


selectcombinded <- combinded[,c(1,2,3,23,5,6,133,134,7,8,9,10,11,13,16:53,54,56,57,59,60,62,63,65,66,68,69,71,72,74,93,
                                95,109,111,113,119,122,123,124,135,136,137,138,139,140,141)]
names(selectcombinded)
names(selectcombinded)[2] <- "CHROM"
names(selectcombinded)[3] <- "POS"
names(selectcombinded)[4] <- "ID"
names(selectcombinded)[5] <- "REF"
names(selectcombinded)[6] <- "ALT"
names(selectcombinded)[7] <- "QUAL"
names(selectcombinded)[8] <- "FILTER"
names(selectcombinded)[76] <- "INFO"
names(selectcombinded)[77] <- "FORMAT"
names(selectcombinded)[78] <- opt$sample
names(selectcombinded)

selectcombinded[,"Orpha"] <- gsub("<br>", " ", selectcombinded[,"Orpha"])
selectcombinded[,"Orpha"] <- gsub("or&nbsp;", " ", selectcombinded[,"Orpha"])
selectcombinded[,"Orpha"] <- gsub("~", " ", selectcombinded[,"Orpha"])

annovar <- selectcombinded[,c(-1)]
annovar[which(annovar[,"ALT"]=="-"),"POS"] <-  annovar[which(annovar[,"ALT"]=="-"),"POS"]-1
annovar <- tidyr::unite(annovar, index, c("CHROM","POS"), sep=":", remove=F)


##GO_BP
bp <- read.delim(opt$'indel-bp', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
bp <- bp[grep("MSigDb",bp[,"INFO"]),]
bp[,"GO_BP"] <- sapply(strsplit(bp[,"INFO"], "MSigDb="), "[", 2)
bp <- tidyr::unite(bp, index, c("X.CHROM","POS"), sep=":", remove=F)
which(duplicated(bp[,"index"]))
#rm duplicate
if (length(which(duplicated(bp[,"index"])))!=0) bp <- bp[-which(duplicated(bp[,"index"])),]

##GO_CC
cc <- read.delim(opt$'indel-cc', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
cc <- cc[grep("MSigDb",cc[,"INFO"]),]
cc[,"GO_CC"] <- sapply(strsplit(cc[,"INFO"], "MSigDb="), "[", 2)
cc <- tidyr::unite(cc, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(cc[,"index"])))!=0) cc <- cc[-which(duplicated(cc[,"index"])),]

##GO_MF
mf <- read.delim(opt$'indel-mf', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
mf <- mf[grep("MSigDb",mf[,"INFO"]),]
mf[,"GO_MF"] <- sapply(strsplit(mf[,"INFO"], "MSigDb="), "[", 2)
mf <- tidyr::unite(mf, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(mf[,"index"])))!=0) mf <- mf[-which(duplicated(mf[,"index"])),]


##KEGG_PATHWAY
KEGG <- read.delim(opt$'indel-kegg', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
KEGG <- KEGG[grep("MSigDb",KEGG[,"INFO"]),]
KEGG[,"KEGG_PATHWAY"] <- sapply(strsplit(KEGG[,"INFO"], "MSigDb="), "[", 2)
KEGG <- tidyr::unite(KEGG, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(KEGG[,"index"])))!=0) KEGG <- KEGG[-which(duplicated(KEGG[,"index"])),]

##PID_PATHWAY
PID <- read.delim(opt$'indel-pid', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
PID <- PID[grep("MSigDb",PID[,"INFO"]),]
PID[,"PID_PATHWAY"] <- sapply(strsplit(PID[,"INFO"], "MSigDb="), "[", 2)
PID <- tidyr::unite(PID, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(PID[,"index"])))!=0) PID <- PID[-which(duplicated(PID[,"index"])),]

##BIOCARTA_PATHWAY
biocarta <- read.delim(opt$'indel-biocarta', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
biocarta <- biocarta[grep("MSigDb",biocarta[,"INFO"]),]
biocarta[,"BIOCARTA_PATHWAY"] <- sapply(strsplit(biocarta[,"INFO"], "MSigDb="), "[", 2)
biocarta <- tidyr::unite(biocarta, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(biocarta[,"index"])))!=0) biocarta <- biocarta[-which(duplicated(biocarta[,"index"])),]


##REACTOME_PATHWAY
reactome <- read.delim(opt$'indel-reactome', stringsAsFactors = FALSE, header = TRUE, na.strings = c(NA, ".", ""),skip=157)
reactome <- reactome[grep("MSigDb",reactome[,"INFO"]),]
reactome[,"REACTOME_PATHWAY"] <- sapply(strsplit(reactome[,"INFO"], "MSigDb="), "[", 2)
reactome <- tidyr::unite(reactome, index, c("X.CHROM","POS"), sep=":", remove=F)
#rm duplicate
if (length(which(duplicated(reactome[,"index"])))!=0) reactome <- reactome[-which(duplicated(reactome[,"index"])),]



##combinded
combinded <- merge(x= annovar, y= bp[,c("index", "GO_BP")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= cc[,c("index", "GO_CC")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= mf[,c("index", "GO_MF")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= KEGG[,c("index", "KEGG_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= PID[,c("index", "PID_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= biocarta[,c("index", "BIOCARTA_PATHWAY")], by= "index", all.x = T)
combinded <- merge(x= combinded, y= reactome[,c("index", "REACTOME_PATHWAY")], by= "index", all.x = T)

combinded[which(combinded[,"ALT"]=="-"),"POS"] <-  combinded[which(combinded[,"ALT"]=="-"),"POS"]+1

names(combinded)

names(combinded)[22] <- "avsnp150"
names(combinded)[29] <- "1000g2015aug_eas"
names(combinded)[30] <- "1000g2015aug_sas"
names(combinded)[31] <- "1000g2015aug_eur"
names(combinded)[32] <- "1000g2015aug_afr"
names(combinded)[33] <- "1000g2015aug_amr"
names(combinded)[34] <- "1000g2015aug_all"
names(combinded)[69] <- "GERP++_RS"

combinded <- combinded[,c(-1)]

write.table(combinded, opt$'indel-vcf', sep="\t",quote = F,na = ".",row.names = F) 