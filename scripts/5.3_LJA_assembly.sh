#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=LJA
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/04_LJA_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/04_LJA_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

WORKDIR="/data/users/aballah/assembly_annotation_course"
READS="${WORKDIR}/outputs/trimmed_reads/ERR11437337.pass.fastq.gz"

OUTDIR="${WORKDIR}/outputs//lja_assembly"
mkdir -p "$OUTDIR"

# Container
LJA_SIF="/containers/apptainer/lja-0.2.sif"

apptainer exec --bind /data "$LJA_SIF" lja -o "$OUTDIR" --reads "$READS"
