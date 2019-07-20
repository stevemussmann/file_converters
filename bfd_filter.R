#!/usr/bin/Rscript

library(phrynomics)
library(optparse)

option_list = list(
	make_option(
		c("-f", "--file"), 
		type="character", 
		default=NULL, 
		help="file in Nexus format", 
		metavar="character"
	),
	make_option(
		c("-m", "--miss"),
		type="double",
		default=0.95,
		help="minimum missing data threshold",
		metavar="double",
	)
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file)){
	print_help(opt_parser)
	stop("Input file must be provided.", call.=FALSE)
}

snps <- ReadSNP(opt$file,fileFormat="nex")
snps <- ReduceMinInd(snps, calc="sites", threshold=opt$miss)
snps <- RemoveNonBinary(snps)
snps <- RemoveInvariantSites(snps)
snps <- TranslateBases(snps, translateMissingChar="?", ordered=TRUE)

WriteSNP(snps, "filtered.nex", format="nexus", missing="?")

