#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=hifiasm
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/04_hifiasm_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/04_hifiasm_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end



WORKDIR="/data/users/aballah/assembly_annotation_course"
READS="${WORKDIR}/outputs/trimmed_reads/ERR11437337.pass.fastq.gz"

OUTDIR="${WORKDIR}/outputs/hifiasm"
mkdir -p "$OUTDIR"

# Container
HIFIASM_SIF="/containers/apptainer/hifiasm_0.25.0.sif"

# Run hifiasm
apptainer exec --bind /data "$HIFIASM_SIF" hifiasm -o "$OUTDIR/hifiasm" -t 32 "$READS"

awk '/^S/{print ">"$2;print $3}' "$OUTDIR/hifiasm.bp.p_ctg.gfa" > "$OUTDIR/assembly.fa"