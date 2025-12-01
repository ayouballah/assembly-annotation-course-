# GENESPACE R script for synteny analysis
library(GENESPACE)

# Working directory
wd <- "/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace"

# Path to MCScanX
path2mcscanx <- "/data/courses/assembly-annotation-course/CDS_annotation/softwares/MCScanX"

# Initialize GENESPACE
gpar <- init_genespace(
    wd = wd,
    path2mcscanx = path2mcscanx,
    nCores = 16
)

# Run GENESPACE
out <- run_genespace(gpar, overwrite = TRUE)

# Generate riparian plots
pdf_bp <- file.path(wd, "TAIR10_bp_riparian.pdf")
pdf_ord <- file.path(wd, "TAIR10_ord_riparian.pdf")

plot_riparian(
    gsParam = out,
    refGenome = "TAIR10",
    pdfFile = pdf_bp,
    useOrder = FALSE
)

plot_riparian(
    gsParam = out,
    refGenome = "TAIR10",
    pdfFile = pdf_ord,
    useOrder = TRUE
)

message("GENESPACE analysis and plots completed!")
