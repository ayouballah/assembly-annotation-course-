#!/bin/bash

#SBATCH --job-name=TEsorter
#SBATCH --cpus-per-task=20
#SBATCH --time=2-00:00:00
#SBATCH --mem=128G
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/TEsorter_%j.o
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/TEsorter_%j.e
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end





APPTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
READS="$WORKDIR/results/EDTA_annotation/assembly.fa.mod.EDTA.raw/assembly.fa.mod.LTR.raw.fa"
OUTDIR="$WORKDIR/annotation/TEsorter"

mkdir -p "$OUTDIR"

cd "$OUTDIR"

apptainer exec --bind "$WORKDIR,/data/courses" "$APPTAINER" TEsorter "$READS" -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"