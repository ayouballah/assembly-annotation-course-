#!/bin/bash
#SBATCH --job-name=maker_output_prep
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=5
#SBATCH --mem=16G
#SBATCH --time=1-00:00:00 
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/maker_output_prep_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/maker_output_prep_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Directories
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
MAKER_OUTPUT_DIR="$WORKDIR/results/MAKER_MPI"
PREP_OUTPUT_DIR="$WORKDIR/results/maker_prep"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Create output directory
mkdir -p "$PREP_OUTPUT_DIR"
cd "$PREP_OUTPUT_DIR"

# Find the MAKER master datastore index log file
# Adjust the assembly name pattern if needed (e.g., assembly.maker.output)
DATASTORE_LOG=$(find "$MAKER_OUTPUT_DIR" -name "*_master_datastore_index.log" | head -1)

if [ -z "$DATASTORE_LOG" ]; then
    echo "ERROR: Could not find MAKER datastore index log in $MAKER_OUTPUT_DIR"
    echo "Looking for files matching: *_master_datastore_index.log"
    echo "Files found:"
    ls -lh "$MAKER_OUTPUT_DIR"
    exit 1
fi

echo "Found MAKER datastore log: $DATASTORE_LOG"

# Merge MAKER GFF3 files (with sequences)
echo "Merging GFF3 files with sequences..."
$MAKERBIN/gff3_merge -s -d "$DATASTORE_LOG" > assembly.all.maker.gff

# Merge MAKER GFF3 files (without sequences, for easier viewing)
echo "Merging GFF3 files without sequences..."
$MAKERBIN/gff3_merge -n -s -d "$DATASTORE_LOG" > assembly.all.maker.noseq.gff

# Merge FASTA files (proteins and transcripts)
echo "Merging FASTA files..."
$MAKERBIN/fasta_merge -d "$DATASTORE_LOG" -o assembly

echo "MAKER output preparation complete!"
echo "Output files in: $PREP_OUTPUT_DIR"
ls -lh "$PREP_OUTPUT_DIR"
