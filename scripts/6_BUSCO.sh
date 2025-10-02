#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Busco
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

WORKDIR="/data/users/aballah/assembly_annotation_course"
ASSEMBLY_HIFIASM="${WORKDIR}/outputs/hifiasm/assembly.fa"
ASSEMBLY_LJA="${WORKDIR}/outputs/lja_assembly/assembly.fasta"
ASSEMBLY_FLYE="${WORKDIR}/outputs/flye/assembly.fasta"
ASSEMBLY_TRINITY="${WORKDIR}/data/trinity.Trinity.fasta"

OUT_DIR="${WORKDIR}/outputs/busco"

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/hifiasm $OUT_DIR/flye $OUT_DIR/lja $OUT_DIR/trinity

# Run BUSCO analyses using the module (not container)

# Run BUSCO on hifiasm assembly
busco --in $ASSEMBLY_HIFIASM \
      --mode genome \
      --auto-lineage \
      --cpu 16 \
      --out busco_hifiasm \
      --out_path $OUT_DIR/hifiasm

# Run BUSCO on flye assembly  
busco --in $ASSEMBLY_FLYE \
      --mode genome \
      --auto-lineage \
      --cpu 16 \
      --out busco_flye \
      --out_path $OUT_DIR/flye

# Run BUSCO on LJA assembly
busco --in $ASSEMBLY_LJA \
      --mode genome \
      --auto-lineage \
      --cpu 16 \
      --out busco_lja \
      --out_path $OUT_DIR/lja

# Run BUSCO on Trinity assembly
busco --in $ASSEMBLY_TRINITY \
      --mode transcriptome \
      --auto-lineage \
      --cpu 16 \
      --out busco_trinity \
      --out_path $OUT_DIR/trinity