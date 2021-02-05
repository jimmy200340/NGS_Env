#optparse module
suppressPackageStartupMessages(library("optparse"))

#Initial args type
option_list <- list(
	make_option("--annovar-snp", help = "annovar multianno file path"),
	make_option("--intervar-snp", help = "intervar multianno file path"),
	make_option("--snp-bp", help = "snpsift_bp vcf file path"),
	make_option("--snp-cc", help = "snpsift_cc vcf file path"),
	make_option("--snp-mf", help = "snpsift_mf vcf file path"),
	make_option("--snp-kegg", help = "snpsift_kegg vcf file path"),
	make_option("--snp-pid", help = "snpsift_pid vcf file path"),
	make_option("--snp-biocarta", help = "snpsift_biocarta vcf file path"),
	make_option("--snp-reactome", help = "snpsift_reactome vcf file path"),
	make_option("--snp-vcf", help = "snp vcf file path"),
	make_option("--annovar-indel", help = "annovar multianno file path"),
	make_option("--intervar-indel", help = "intervar multianno file path"),
	make_option("--indel-bp", help = "snpsift_bp vcf file path"),
	make_option("--indel-cc", help = "snpsift_cc vcf file path"),
	make_option("--indel-mf", help = "snpsift_mf vcf file path"),
	make_option("--indel-kegg", help = "snpsift_kegg vcf file path"),
	make_option("--indel-pid", help = "snpsift_pid vcf file path"),
	make_option("--indel-biocarta", help = "snpsift_biocarta vcf file path"),
	make_option("--indel-reactome", help = "snpsift_reactome vcf file path"),
	make_option("--indel-vcf", help = "indel vcf file path")
)

#parse args to code
opt <- parse_args(OptionParser(option_list=option_list))

#Stop if args are null
if (is.null(opt$target_CB))
{
  print_help(opt_parser)
  stop("--target_CB required.", call.=FALSE)
}

print (opt$annovar-snp)