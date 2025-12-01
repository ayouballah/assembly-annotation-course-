#!/usr/bin/env bash
#SBATCH --job-name=orthofinder
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/orthofinder_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/orthofinder_%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=pibu_el8

# =============================================================================
# 19_orthofinder.sh - OrthoFinder Analysis 
# Run after 18_genespace_prepare.sh to find orthologs across genomes
# =============================================================================

module load Apptainer/1.3.4-GCCcore-12.3.0

WORKDIR=/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation

# Run OrthoFinder on peptide files
apptainer exec \
    --bind ${WORKDIR}:${WORKDIR} \
    ${COURSEDIR}/containers/orthofinder_3.0.1b1.sif \
    orthofinder \
    -f ${WORKDIR}/peptide \
    -o ${WORKDIR}/orthofinder \
    -t ${SLURM_CPUS_PER_TASK}

echo "OrthoFinder completed!"
