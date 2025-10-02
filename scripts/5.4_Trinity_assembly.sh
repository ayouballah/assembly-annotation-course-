#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=TRINITY
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/06_trinity_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/06_trinity_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

WORKDIR="/data/users/aballah/assembly_annotation_course"
RNA1="${WORKDIR}/outputs/trimmed_reads/ERR754081_1.trim.fastq.gz"
RNA2="${WORKDIR}/outputs/trimmed_reads/ERR754081_2.trim.fastq.gz"
OUTDIR="${WORKDIR}/outputs/trinity"
mkdir -p "$OUTDIR"

module load Java 
module load Trinity/2.15.1-foss-2021a

Trinity \
  --seqType fq \
  --left "$RNA1" \
  --right "$RNA2" \
  --max_memory 128G \
  --CPU $SLURM_CPUS_PER_TASK \
  --output "$OUTDIR"
