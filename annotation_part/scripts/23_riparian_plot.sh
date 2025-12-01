#!/usr/bin/env bash
#SBATCH --job-name=riparian_plot
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/riparian_plot_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/riparian_plot_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=pibu_el8

# Load container module
module load Apptainer/1.3.4-GCCcore-12.3.0

WORKDIR=/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
CONTAINER=${COURSEDIR}/containers/genespace_1.3.1.sif

# Run riparian plot generation
apptainer exec \
    --bind ${WORKDIR}:${WORKDIR} \
    --bind ${COURSEDIR}:${COURSEDIR} \
    ${CONTAINER} \
    Rscript -e "
library(GENESPACE)
wd <- '${WORKDIR}'
load(file.path(wd, 'results', 'gsParams.rda'))

# Riparian plot by base pairs
plot_riparian(
    gsParam = gsParams,
    refGenome = 'TAIR10',
    pdfFile = file.path(wd, 'TAIR10_bp_riparian.pdf'),
    useOrder = FALSE
)

# Riparian plot by gene order
plot_riparian(
    gsParam = gsParams,
    refGenome = 'TAIR10',
    pdfFile = file.path(wd, 'TAIR10_ord_riparian.pdf'),
    useOrder = TRUE
)
"

echo "Riparian plots generated!"
ls -la ${WORKDIR}/*.pdf
