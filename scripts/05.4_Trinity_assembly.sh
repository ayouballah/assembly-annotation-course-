#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=TRINITY
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/03_trinity_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/03_trinity_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end


WORKDIR="/data/users/aballah/assembly_annotation_course"
READS="${WORKDIR}/outputs/trimmed_reads/ERR11437337.pass.fastq.gz"
OUTPUT_DIR="${WORKDIR}/outputs/trinity"
mkdir -p "$OUTPUT_DIR"

module load Trinity/2.15.1-foss-2021a

#run Trinity
Trinity --seqType fq --left $READS --right $READS --max_memory 64G --CPU 16 --output $OUTPUT_DIR