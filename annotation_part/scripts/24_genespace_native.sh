#!/usr/bin/env bash
#SBATCH --job-name=genespace_native
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_native_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_native_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --partition=pibu_el8

# Use native R instead of container
module load R/4.2.1-foss-2021a

# Define variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
GENESPACE_DIR="${WORKDIR}/results/genespace"

# MCScanX from course directory
export PATH="/data/courses/assembly-annotation-course/CDS_annotation/softwares/MCScanX:$PATH"

echo "=== GENESPACE Analysis (Native R) ==="
echo "Working directory: ${GENESPACE_DIR}"
echo "R version: $(R --version | head -1)"
echo ""

# Run GENESPACE
Rscript ${WORKDIR}/scripts/24_genespace_native.R ${GENESPACE_DIR}

echo ""
echo "DONE!"
