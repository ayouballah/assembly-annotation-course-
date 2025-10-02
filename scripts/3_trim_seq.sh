#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=fastp
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/03_fastp_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/03_fastp_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

WORKDIR="/data/users/aballah/assembly_annotation_course"
OUTDIR="${WORKDIR}/outputs/trimmed_reads"
mkdir -p "$OUTDIR"

RNA1="${WORKDIR}/data/RNAseq_Sha/ERR754081_1.fastq.gz"
RNA2="${WORKDIR}/data/RNAseq_Sha/ERR754081_2.fastq.gz"
ACCESSION="Sf-2"
HIFI="$(ls -1 ${WORKDIR}/data/${ACCESSION}/*.fastq.gz | head -n1)"

FASTP_IMAGE="/containers/apptainer/fastp_0.24.1.sif"

# RNA-seq trimming + report
apptainer exec --bind /data "$FASTP_IMAGE" fastp \
  -i "$RNA1" -I "$RNA2" \
  -o "${OUTDIR}/ERR754081_1.trim.fastq.gz" \
  -O "${OUTDIR}/ERR754081_2.trim.fastq.gz" \
  -w 4 \
  -j "${OUTDIR}/RNA_fastp.json" \
  -h "${OUTDIR}/RNA_fastp.html"

# HiFi report only (no filtering)
apptainer exec --bind /data "$FASTP_IMAGE" fastp \
  -i "$HIFI" \
  -o "${OUTDIR}/$(basename "${HIFI%.fastq.gz}").pass.fastq.gz" \
  --disable_length_filtering \
  -w 4 \
  -j "${OUTDIR}/HIFI_fastp.json" \
  -h "${OUTDIR}/HIFI_fastp.html"
