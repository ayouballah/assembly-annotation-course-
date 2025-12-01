#!/usr/bin/env bash
#SBATCH --job-name=genespace
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=pibu_el8

# Load container module
module load Apptainer/1.3.4-GCCcore-12.3.0

WORKDIR=/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
CONTAINER=${COURSEDIR}/containers/genespace_1.3.1.sif

# Run GENESPACE via container
apptainer exec \
    --bind ${WORKDIR}:${WORKDIR} \
    --bind ${COURSEDIR}:${COURSEDIR} \
    ${CONTAINER} \
    Rscript ${WORKDIR}/run_genespace.R

echo "GENESPACE analysis completed!"
