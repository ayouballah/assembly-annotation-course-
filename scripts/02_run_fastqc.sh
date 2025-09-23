#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=fastqc
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/02_fastqc_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/02_fastqc_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# Define directories and files
WORKDIR="/data/users/aballah/assembly_annotation_course"
DNA="${WORKDIR}/data/Sf-2/ERR11437337.fastq.gz"
RNA1="${WORKDIR}/data/RNAseq_Sha/ERR754081_1.fastq.gz"
RNA2="${WORKDIR}/data/RNAseq_Sha/ERR754081_2.fastq.gz"
OUTPUT_DIR="${WORKDIR}/outputs/fastqc"



# Apptainer FastQC and MultiQC image path
FASTQC_IMAGE="/containers/apptainer/fastqc-0.12.1.sif"
MULTIQC_IMAGE="/containers/apptainer/multiqc-1.19.sif"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Run FastQC using Apptainer
apptainer exec --bind /data "${FASTQC_IMAGE}" fastqc "$DNA" --outdir="$OUTPUT_DIR"
apptainer exec --bind /data "${FASTQC_IMAGE}" fastqc "$RNA1" --outdir="$OUTPUT_DIR"
apptainer exec --bind /data "${FASTQC_IMAGE}" fastqc "$RNA2" --outdir="$OUTPUT_DIR"
# Run MultiQC to aggregate FastQC reports
apptainer exec --bind /data "${MULTIQC_IMAGE}" multiqc "$OUTPUT_DIR" --outdir="$OUTPUT_DIR"
