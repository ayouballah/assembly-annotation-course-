#!/usr/bin/env bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --job-name=TEsorter
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/TEsorter%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/TEsorter%j.err

#SBATCH --partition=pibu_el8

WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part/results/EDTA_annotation"
TELIB_FILE="$WORKDIR/assembly.fa.mod.EDTA.TElib.fa"
OUTPUT_DIR="$WORKDIR/TEsorter_results"

# Create output directory
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

module load SeqKit/2.6.1 

# Extract Copia sequences
seqkit grep -r -p "Copia" $TELIB_FILE > Copia_sequences.fa
# Extract Gypsy sequences
seqkit grep -r -p "Gypsy" $TELIB_FILE > Gypsy_sequences.fa

# Run TEsorter on Copia sequences
apptainer exec -C -H $WORKDIR -H ${PWD}:/work --writable-tmpfs -u /data/courses/assembly-annotation-\
course/CDS_annotation/containers/TEsorter_1.3.0.sif TEsorter Copia_sequences.fa -db rexdb-plant

# Run TEsorter on Gypsy sequences
apptainer exec -C -H $WORKDIR -H ${PWD}:/work --writable-tmpfs -u /data/courses/assembly-annotation-\
course/CDS_annotation/containers/TEsorter_1.3.0.sif TEsorter Gypsy_sequences.fa -db rexdb-plant