#!/usr/bin/env Rscript

# GENESPACE analysis using native R (not container)
# This script installs GENESPACE from GitHub and runs the full pipeline

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Create user library if needed
user_lib <- Sys.getenv("R_LIBS_USER")
if (!dir.exists(user_lib)) {
  dir.create(user_lib, recursive = TRUE)
}
.libPaths(c(user_lib, .libPaths()))

cat("=== Installing required packages ===\n")

# Install BiocManager if needed
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

# Set Bioconductor version for R 4.2.x
BiocManager::install(version = "3.16", ask = FALSE)

# Install Bioconductor dependencies first
cat("Installing Bioconductor dependencies...\n")
BiocManager::install(c("Biostrings", "rtracklayer"), update = FALSE, ask = FALSE)

# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install GENESPACE from GitHub
cat("Installing GENESPACE from GitHub...\n")
devtools::install_github("jtlovell/GENESPACE", upgrade = "never", force = FALSE)

# Load GENESPACE
library(GENESPACE)
cat("GENESPACE loaded successfully!\n")

# Set up paths
wd <- "/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace"
path2mcscanx <- "/data/courses/assembly-annotation-course/CDS_annotation/softwares/MCScanX"

cat("Working directory:", wd, "\n")
cat("MCScanX path:", path2mcscanx, "\n")

# Initialize GENESPACE
cat("\n=== Initializing GENESPACE ===\n")
gpar <- init_genespace(
  wd = wd,
  path2mcscanx = path2mcscanx,
  nCores = 4
)

# Run GENESPACE
cat("\n=== Running GENESPACE ===\n")
out <- run_genespace(gpar, overwrite = TRUE)

cat("\n=== GENESPACE run completed ===\n")

# Generate riparian plots
cat("\n=== Generating Riparian Plots ===\n")

# Plot 1: Base-pair coordinates (like the friend's 05-TAIR10_bp.rip.pdf)
pdf_bp <- file.path(wd, "TAIR10_bp_riparian.pdf")
cat("Creating base-pair riparian plot:", pdf_bp, "\n")

plot_riparian(
  gsParam = out,
  refGenome = "TAIR10",
  pdfFile = pdf_bp,
  useOrder = FALSE,  # Use bp coordinates
  reorderChrs = TRUE,
  labelTheseGenomes = c("TAIR10", "Sf2"),
  highlightRef = "TAIR10",
  braidAlpha = 0.5,
  chrFill = "lightgrey"
)

# Plot 2: Gene-order based
pdf_ord <- file.path(wd, "TAIR10_ord_riparian.pdf")
cat("Creating gene-order riparian plot:", pdf_ord, "\n")

plot_riparian(
  gsParam = out,
  refGenome = "TAIR10",
  pdfFile = pdf_ord,
  useOrder = TRUE,  # Use gene order
  reorderChrs = TRUE,
  labelTheseGenomes = c("TAIR10", "Sf2"),
  highlightRef = "TAIR10",
  braidAlpha = 0.5,
  chrFill = "lightgrey"
)

cat("\n=== All plots generated successfully! ===\n")
cat("Output files:\n")
cat("  -", pdf_bp, "\n")
cat("  -", pdf_ord, "\n")

# Save the output object for future use
saveRDS(out, file.path(wd, "genespace_output.rds"))
cat("  -", file.path(wd, "genespace_output.rds"), "\n")

cat("\n=== Done! ===\n")
