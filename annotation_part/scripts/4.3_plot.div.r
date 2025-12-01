#!/usr/bin/env Rscript

# TE Age Estimation Script
# This script analyzes TE divergence from parseRM output and estimates insertion ages

# Function to install packages if missing
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    message("Installing missing package: ", pkg)
    install.packages(pkg, repos = "https://cloud.r-project.org/", quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# Install/load required packages
install_if_missing("reshape2")
install_if_missing("tidyverse")
install_if_missing("data.table")
install_if_missing("cowplot")
install_if_missing("scales")

# Input data file (parseRM output)
# Adjust this path to match your actual parseRM output filename
WORKDIR <- "/data/users/aballah/assembly_annotation_course/annotation_part"
data_file <- file.path(WORKDIR, "results/parseRM/assembly.fa.mod.out.landscape.Div.Rname.tab")

# Output directory for plots
outdir <- file.path(WORKDIR, "results/parseRM/plots")
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# Check if input file exists
if (!file.exists(data_file)) {
  stop("ERROR: Input file not found: ", data_file, "\n",
       "Make sure parseRM.pl has completed successfully!")
}

message("Reading TE divergence data from: ", data_file)

# Read parseRM output
rep_table <- fread(data_file, header = FALSE, sep = "\t")

# Set column names (divergence bins 1-50%)
colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)

# Remove unknown families
rep_table <- rep_table %>% filter(Rfam != "unknown")

# Create combined family identifier
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

message("TE superfamilies found:")
print(table(rep_table$fam))

# Melt data to long format
rep_table.m <- melt(rep_table, id.vars = c("Rname", "Rclass", "Rfam", "fam"))

# Remove divergence bin 1 (library sequences inflate this peak)
rep_table.m <- rep_table.m %>% filter(variable != "1")

# Order superfamilies for consistent plotting
# NOTE: Adjust this list based on YOUR superfamilies from the table above
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", 
  "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", 
  "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM"
))

# Convert divergence to proportion (bins are in percent)
rep_table.m$distance <- as.numeric(as.character(rep_table.m$variable)) / 100

# Remove Helitrons (EDTA cannot annotate them properly)
# See: https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron")

#-------------------------------------------------
# Plot 1: TE Divergence Landscape (no age axis)
#-------------------------------------------------
message("Generating divergence plot...")

p1 <- ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Divergence (proportion)") +
  ylab("Sequence (Mbp)") +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  ) +
  ggtitle("TE Divergence Landscape")

ggsave(
  filename = file.path(outdir, "TE_divergence_landscape.pdf"),
  plot = p1,
  width = 10,
  height = 5,
  useDingbats = FALSE
)

ggsave(
  filename = file.path(outdir, "TE_divergence_landscape.png"),
  plot = p1,
  width = 10,
  height = 5,
  dpi = 300
)

#-------------------------------------------------
# Plot 2: TE Divergence with Age Estimation
#-------------------------------------------------
message("Calculating TE insertion ages...")

# Brassicaceae synonymous substitution rate (per site per year)
# Source: Koch et al. (2000), Ossowski et al. (2010)
r <- 8.22e-9

# Calculate ages using Kimura 2-parameter distance
# Formula: Age (years) = Divergence / (2 × substitution_rate)
# The factor of 2 accounts for divergence accumulating in both lineages
rep_table.m <- rep_table.m %>%
  mutate(
    age_years = distance / (2 * r),
    age_Myr   = age_years / 1e6    # Convert to million years
  )

message("Age range: ", round(min(rep_table.m$age_Myr, na.rm = TRUE), 2), 
        " - ", round(max(rep_table.m$age_Myr, na.rm = TRUE), 2), " Myr")

p2 <- ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1e6)) +
  geom_bar() +
  theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  scale_x_continuous(
    name = "Divergence (proportion)",
    sec.axis = sec_axis(
      ~ . / (2 * r) / 1e6, 
      name = "Estimated insertion age (Myr)"
    )
  ) +
  ylab("Sequence (Mbp)") +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  ) +
  ggtitle("TE Divergence Landscape with Age Estimation")

ggsave(
  filename = file.path(outdir, "TE_divergence_with_age.pdf"),
  plot = p2,
  width = 10,
  height = 5,
  useDingbats = FALSE
)

ggsave(
  filename = file.path(outdir, "TE_divergence_with_age.png"),
  plot = p2,
  width = 10,
  height = 5,
  dpi = 300
)

message("Plots saved to: ", outdir)
message("Complete!")

#-------------------------------------------------
# Notes on interpretation:
#-------------------------------------------------
# - Why plot in Mbp instead of counts?
#   Nested insertions and deletions fragment TEs into many small pieces.
#   Using counts would overrepresent fragmented old TEs.
#   Using sequence length (Mbp) gives a more accurate view of genomic impact.
#
# - Age estimation assumptions:
#   1. Neutral substitution rate is constant over time
#   2. TEs are no longer active (not under selection)
#   3. Substitution rate for Brassicaceae applies to your species
#   4. CpG hypermutation has been corrected by parseRM.pl
