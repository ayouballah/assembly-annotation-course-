#!/bin/bash
#SBATCH --job-name=MAKER
#SBATCH --partition=pibu_el8 
#SBATCH --cpus-per-task=4 
#SBATCH --mem=8G 
#SBATCH --time=12:00:00 
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/MAKER_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/MAKER_%j.err

#directories
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part/results"
OUTPUT_DIR="${WORKDIR}/MAKER_control"

#make path to outdir if it doesnt exist
mkdir -p $OUTPUT_DIR

#change path to outdir
cd "$OUTPUT_DIR"

CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

apptainer exec --bind ${WORKDIR} ${CONTAINER} maker -CTL
