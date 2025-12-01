#!/usr/bin/env bash
#SBATCH --job-name=pangenome
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/pangenome_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/pangenome_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=pibu_el8

# Pangenome analysis using GENESPACE output
module load R/4.2.1-foss-2021a

WORKDIR=/data/users/aballah/assembly_annotation_course/annotation_part/results/genespace

Rscript /data/users/aballah/assembly_annotation_course/annotation_part/scripts/25_pangenome.R

echo "Pangenome analysis complete!"
ls -la ${WORKDIR}/pangenome*.pdf ${WORKDIR}/pangenome*.tsv 2>/dev/null
