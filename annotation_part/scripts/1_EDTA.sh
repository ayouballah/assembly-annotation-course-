#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=edta
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/01_edta_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/01_edta_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# load modules


# set variables
WORK_DIR=/data/users/aballah/assembly_annotation_course/annotation_part
ASSEMBLY_HIFIASM=/data/users/aballah/assembly_annotation_course/outputs/hifiasm/assembly.fa


OUT_DIR=/data/users/aballah/assembly_annotation_course/annotation_part/results/EDTA_annotation

CONTAINER_SIF=/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif
CDS_FILE=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated

# create directory and enter it
mkdir -p $OUT_DIR && cd $OUT_DIR

# run EDTA
# --genome [File]		The genome FASTA file. Required.
# --species [Rice|Maize|others]	Specify the species for identification of TIR candidates. Default: others
# --step [all|filter|final|anno]	Specify which steps you want to run EDTA. all: run the entire pipeline (default)
# --cds [File]		Provide a FASTA file containing the coding sequence (no introns, UTRs, nor TEs) of this genome or its close relative.
#  --anno [0|1]	Perform (1) or not perform (0, default) whole-genome TE annotation after TE library construction.
# --threads|-t	[int]	Number of theads to run this script (default: 4)

apptainer exec \
    --bind /data \
    $CONTAINER_SIF \
    EDTA.pl \
    --genome $ASSEMBLY_HIFIASM \
    --species others \
    --step all \
    --cds $CDS_FILE \
    --anno 1 \
    --threads $SLURM_CPUS_PER_TASK   