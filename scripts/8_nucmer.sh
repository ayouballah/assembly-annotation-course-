#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=nucmer
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/8_nucmer_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/8_nucmer_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

WORKDIR="/data/users/aballah/assembly_annotation_course"
REF=${WORKDIR}/data/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
FLYE="${WORKDIR}/outputs/flye/assembly.fasta"
HIFIASM="$WORKDIR/outputs/hifiasm/assembly.fa"
LJA="$WORKDIR/outputs/lja_assembly/assembly.fasta"
RESULTDIR="${WORKDIR}/outputs/genomes_comparison_1"
mkdir -p $RESULTDIR

#nucmer - align assemblies to reference genome
cd $RESULTDIR

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix genome_flye \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $REF $FLYE 

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix genome_hifiasm \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $REF $HIFIASM 

apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix genome_LJA \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $REF $LJA

# Compare genomes against each other (genome-to-genome comparisons)
echo "Comparing assemblies against each other..."

# Flye vs Hifiasm
apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix flye_vs_hifiasm \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $FLYE $HIFIASM

# Flye vs LJA  
apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix flye_vs_LJA \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $FLYE $LJA

# Hifiasm vs LJA
apptainer exec --bind /data \
    /containers/apptainer/mummer4_gnuplot.sif nucmer \
    --prefix hifiasm_vs_LJA \
    --breaklen 1000 \
    --mincluster 1000 \
    --threads $SLURM_CPUS_PER_TASK \
    $HIFIASM $LJA 
