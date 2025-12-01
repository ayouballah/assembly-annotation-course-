# Load the circlize package
library(circlize)
library(tidyverse)
library(ComplexHeatmap)

# Load the TE annotation GFF3 file
gff_file <- "C:/Users/ayoub/OneDrive - Universitaet Bern/WS_25/assembly and annotation/annotation/assembly.fa.mod.EDTA.TEanno.gff3"

gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$V3 %>% table()

# custom ideogram data
## To make the ideogram data, you need to know the lengths of the scaffolds.
## There is an index file that has the lengths of the scaffolds, the `.fai` file.
## To generate this file you need to run the following command in bash:
## samtools faidx assembly.fasta
## This will generate a file named assembly.fasta.fai
## You can then read this file in R and prepare the custom ideogram data

custom_ideogram <- read.table("C:/Users/ayoub/OneDrive - Universitaet Bern/WS_25/assembly and annotation/annotation/assembly.fasta.fai", header = FALSE, stringsAsFactors = FALSE)
custom_ideogram$chr <- custom_ideogram$V1
custom_ideogram$start <- 1
custom_ideogram$end <- custom_ideogram$V2
custom_ideogram <- custom_ideogram[, c("chr", "start", "end")]
custom_ideogram <- custom_ideogram[order(custom_ideogram$end, decreasing = T), ]
sum(custom_ideogram$end[1:20])

# Select only the first 20 longest scaffolds, You can reduce this number if you have longer chromosome scale scaffolds
custom_ideogram <- custom_ideogram[1:20, ]

# Function to filter GFF3 data based on Superfamily (You need one track per Superfamily)
filter_superfamily <- function(gff_data, superfamily, custom_ideogram) {
  filtered_data <- gff_data[gff_data$V3 == superfamily, ] %>%
    as.data.frame() %>%
    mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
    select(chrom, start, end, strand) %>%
    filter(chrom %in% custom_ideogram$chr)
  return(filtered_data)
}

filtered_data <- gff_data[gff_data$V3 == "Gypsy_LTR_retrotransposon", ] %>%
  as.data.frame() %>%
  mutate(chrom = V1, start = V4, end = V5, strand = V6) %>%
  select(chrom, start, end, strand) %>%
  filter(chrom %in% custom_ideogram$chr)

pdf("C:/Users/ayoub/OneDrive - Universitaet Bern/WS_25/assembly and annotation/annotation/02-TE_density.pdf", width = 10, height = 10)
gaps <- c(rep(1, length(custom_ideogram$chr) - 1), 5) # Add a gap between scaffolds, more gap for the last scaffold
circos.par(start.degree = 90, gap.after = 1, track.margin = c(0, 0), gap.degree = gaps)
# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram)

# Plot the density
circos.genomicDensity(filter_superfamily(gff_data, "Gypsy_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "green", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Copia_LTR_retrotransposon", custom_ideogram), count_by = "number", col = "red", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "CACTA_TIR_transposon", custom_ideogram), count_by = "number", col = "blue", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "Mutator_TIR_transposon", custom_ideogram), count_by = "number", col = "magenta", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "hAT_TIR_transposon", custom_ideogram), count_by = "number", col = "orange", track.height = 0.07, window.size = 1e5)
# We dont have "tRNA_SINE_retrotransposon", but just for legend
circos.genomicDensity(filter_superfamily(gff_data, "tRNA_SINE_retrotransposon", custom_ideogram), count_by = "number", col = "yellow2", track.height = 0.07, window.size = 1e5)
circos.genomicDensity(filter_superfamily(gff_data, "L1_LINE_retrotransposon", custom_ideogram), count_by = "number", col = "purple3", track.height = 0.07, window.size = 1e5)
circos.clear()

lgd <- Legend(
  title = "Superfamily", at = c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", "CACTA_TIR_transposon", "Mutator_TIR_transposon", "hAT_TIR_transposon",  "L1_LINE_retrotransposon"),
  legend_gp = gpar(fill = c("green", "red", "blue", "magenta", "orange", "purple3" ))
)
draw(lgd, x = unit(13, "cm"), y = unit(14, "cm"), just = c("center"))

dev.off()

