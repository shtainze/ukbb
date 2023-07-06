#####################
# This script scans the folder `dir_source`
# and for each file inside it, draw manhattan plots
# for each statistical test and for each gene
#####################

# Startup
library("qqman")  
library("data.table") 
library("stringr")


# Draw only the part around a gene of interest
manhattan_part <- function(df, mode, start, end, thin_interval, filename) {
	if (thin_interval > 1){
		df <- df[seq(1, dim(df)[1], by=thin_interval),]		
	}

	df$CHR <- replace(df$CHR, which(df$CHR=="X"), 23)
	df$CHR <- replace(df$CHR, which(df$CHR=="Y"), 24)
	df$CHR <- replace(df$CHR, which(df$CHR=="XY"), 25)
	df$CHR <- replace(df$CHR, which(df$CHR=="MT"), 26)
	df$CHR <- as.numeric(df$CHR)
	df$P <- as.numeric(df$P)
	# df_all$P <- -(df_all$P) / 2.302585093 # Natural log -> log10
	# df_all$P[is.infinite(df_all$P)] <- 100 # Infinity -> round to 100 (well above the finite log10(P) values)
	df_col <- c("#E60012", "#FFF100", "#009944", "#00A0E9", "#1D2088", 
		"#920783", "#E5004F", "#F39800", "#8FC31F", "#0068B7", 
		"#009E96", "#E4007F", "#333333", "#D7004A", "#1B1C80", 
		"#E48E00", "#009140", "#999999", "#86B81B", "#0097DB",
		 "#8A017C", "#D7000F")
	title <- filename
	title <- str_replace(title, ".*manhattan_", "")
	title <- str_replace(title, ".png", "")


	if (mode=="part"){
		png(filename, width=600,height=400) 
		manhattan(df, xlim=c(start, end), logp=TRUE, genomewideline = -log10(5e-08),
			col=df_col, cex=1, cex.lab=2, cex.axis=1, main=title
			)
	}
	if (mode=="all"){
		png(filename, width=1200,height=800) 
		manhattan(df, logp=TRUE, genomewideline = -log10(5e-08),
			col=df_col, cex=0.5, cex.lab=2, cex.axis=1, main=title
			)
	}
	dev.off()	
}


dir_root <- paste("..", "..",	"..", 
	"analysis", "specific", "analysis_20230529_01_gwas", 
	sep="\\")

file_source = paste(dir_root, "00901_1180-0.0", "for_manhattan_chr1.txt", sep="\\")
df_chr1 <- read.table(file_source, stringsAsFactors=F, sep = " ", header = TRUE, na.strings = "")

file_source = paste(dir_root, "00901_1180-0.0", "for_manhattan_chr11.txt", sep="\\")
df_chr11 <- read.table(file_source, stringsAsFactors=F, sep = " ", header = TRUE, na.strings = "")

file_source = paste(dir_root, "00901_1180-0.0", "for_manhattan.txt", sep="\\")
df_all <- read.table(file_source, stringsAsFactors=F, sep = " ", header = TRUE, na.strings = "")


dir_out = paste(dir_root, "manhattan", sep="\\")

if (!dir.exists(dir_out)){
	dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
}


# PER3 chr1:7,844,714-7,905,237
filename <- paste(dir_out, "manhattan_PER3.png", sep="\\")
manhattan_part(df_chr1, "part", 7744714, 8005237, 1, filename)

# TMEM57 chr1:25757388-25826700
filename <- paste(dir_out, "manhattan_TMEM57.png", sep="\\")
manhattan_part(df_chr1, "part", 25657388, 25926700, 1, filename)

# RHCE chr1:25687853-25747363
filename <- paste(dir_out, "manhattan_RHCE.png", sep="\\")
manhattan_part(df_chr1, "part", 25587853, 25847363, 1, filename)

# TYR chr11:88,911,040-89,028,927
filename <- paste(dir_out, "manhattan_TYR.png", sep="\\")
manhattan_part(df_chr11, "part", 88811040, 89128927, 1, filename)

filename <- paste(dir_out, "manhattan_all_every100.png", sep="\\")
manhattan_part(df_all, "all", 0, 0, 100, filename)

filename <- paste(dir_out, "manhattan_all_every10.png", sep="\\")
manhattan_part(df_all, "all", 0, 0, 10, filename)

df_over_threshold <- df_all[df_all$P < 0.01, ]
filename <- paste(dir_out, "manhattan_all_P_under001.png", sep="\\")
manhattan_part(df_over_threshold, "all", 0, 0, 1, filename)

# Tests
manhattan_part(df_chr1, "part", 150359840, 150580085, 1, paste(dir_out, "manhattan_TARS2.png", sep="\\"))
manhattan_part(df_chr1, "part", 7807672, 8013551, 1, paste(dir_out, "manhattan_UTS2.png", sep="\\"))
manhattan_part(df_chr1, "part", 109991186, 110238465, 1, paste(dir_out, "manhattan_GNAI3.png", sep="\\"))
manhattan_part(df_chr1, "part", 150380487, 150586265, 1, paste(dir_out, "manhattan_ECM1.png", sep="\\"))
manhattan_part(df_chr1, "part", 150154930, 150359505, 1, paste(dir_out, "manhattan_CIART.png", sep="\\"))
manhattan_part(df_chr1, "part", 25657388, 25926700, 1, paste(dir_out, "manhattan_TMEM57.png", sep="\\"))
manhattan_part(df_chr1, "part", 150090717, 150308504, 1, paste(dir_out, "manhattan_ANP32E.png", sep="\\"))
manhattan_part(df_chr1, "part", 179709102, 179947867, 1, paste(dir_out, "manhattan_TOR1AIP2.png", sep="\\"))
manhattan_part(df_chr1, "part", 150193928, 150425704, 1, paste(dir_out, "manhattan_PRPF3.png", sep="\\"))
manhattan_part(df_chr1, "part", 150166262, 150381414, 1, paste(dir_out, "manhattan_MRPS21.png", sep="\\"))
manhattan_part(df_chr1, "part", 150518701, 150769672, 1, paste(dir_out, "manhattan_GOLPH3L.png", sep="\\"))
manhattan_part(df_chr1, "part", 201408243, 201896102, 1, paste(dir_out, "manhattan_NAV1.png", sep="\\"))
manhattan_part(df_chr1, "part", 25587853, 25847363, 1, paste(dir_out, "manhattan_RHCE.png", sep="\\"))


print("")
print("Done.")
