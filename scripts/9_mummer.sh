#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=mmumer
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/9_mmumer_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/9_mmumer_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end


WORKDIR="/data/users/aballah/assembly_annotation_course"
REF=${WORKDIR}/data/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
FLYE="${WORKDIR}/outputs/flye/assembly.fasta"
HIFIASM="$WORKDIR/outputs/hifiasm/assembly.fa"
LJA="$WORKDIR/outputs/lja_assembly/assembly.fasta"
RESULTDIR="${WORKDIR}/outputs/genomes_comparison"
mkdir -p $RESULTDIR

#mummer - generate dot plots from .delta files
cd $RESULTDIR

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif mummerplot \
    -R $REF -Q $FLYE \
    -breaklen 1000 \
    --filter \
    -t png --large --layout --fat \
    -p flye \
    genome_flye.delta

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif mummerplot \
    -R $REF -Q $HIFIASM \
    -breaklen 1000 \
    --filter \
    -t png --large --layout --fat \
    -p hifiasm \
    genome_hifiasm.delta

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif mummerplot \
    -R $REF -Q $LJA \
    -breaklen 1000 \
    --filter \
    -t png --large --layout --fat \
    -p LJA \
    genome_LJA.delta


