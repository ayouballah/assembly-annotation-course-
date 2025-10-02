#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Busco
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_comparison_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_comparison_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a


WORKDIR="/data/users/aballah/assembly_annotation_course"

ASSEMBLY_TRINITY_module="${WORKDIR}/outputs/trinity_container_results.Trinity.fasta"
ASSEMBLY_TRINITY_container="${WORKDIR}/outputs/trinity_container_results.Trinity.fasta"

OUT_DIR="${WORKDIR}/outputs/busco"

# create directory if not available
mkdir -p $OUT_DIR  $OUT_DIR/trinity_container $OUT_DIR/trinity_module

# Run BUSCO on Trinity container assembly
busco --in $ASSEMBLY_TRINITY_container \
      --mode transcriptome \
      --auto-lineage \
      --cpu 16 \
      --out busco_trinity_container \
      --out_path $OUT_DIR/trinity_container

# Run BUSCO on trinity module assembly
busco --in $ASSEMBLY_TRINITY_module \
      --mode transcriptome \
      --auto-lineage \
      --cpu 16 \
      --out busco_trinity_module \
      --out_path $OUT_DIR/trinity_module