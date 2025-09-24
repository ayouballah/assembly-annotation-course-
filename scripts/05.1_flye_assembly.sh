#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=flye
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/03_flye_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/03_flye_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# Directories
WORKDIR="/data/users/aballah/assembly_annotation_course"
READS="${WORKDIR}/outputs/trimmed_reads/ERR11437337.pass.fastq.gz"
OUTDIR="${WORKDIR}/outputs/flye"

# Container
FLYE_IMAGE="/containers/apptainer/flye_2.9.5.sif"

# output directory
mkdir -p "$OUTDIR"

# Run Flye
apptainer exec --bind /data "$FLYE_IMAGE" flye \
    --pacbio-hifi "$READS" \
    --out-dir "$OUTDIR" \
    --threads 16
