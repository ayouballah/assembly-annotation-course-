#!/usr/bin/env bash

#SBATCH --job-name=rename_map
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/rename_map_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/rename_map_%j.err
#SBATCH --cpus-per-task=5
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Define variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
MAKER_PREP_DIR="$WORKDIR/results/maker_prep"
OUTPUT_DIR="$WORKDIR/results/maker_renamed"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Filenames
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

# Change to maker_prep directory
cd "$MAKER_PREP_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if required files exist
if [ ! -f "$gff" ]; then
    echo "ERROR: GFF file not found: $gff"
    echo "Make sure maker_output_prep.sh has completed successfully"
    exit 1
fi

if [ ! -f "$protein" ]; then
    echo "ERROR: Protein file not found: $protein"
    exit 1
fi

if [ ! -f "$transcript" ]; then
    echo "ERROR: Transcript file not found: $transcript"
    exit 1
fi

echo "Found all required MAKER files"
echo "GFF: $gff"
echo "Proteins: $protein"
echo "Transcripts: $transcript"

# Use custom prefix for gene IDs
prefix="sf-2"
echo "Using prefix: $prefix"

# Build ID map from the GFF
echo "Building ID map..."
"$MAKERBIN/maker_map_ids" --prefix "$prefix" --justify 7 "$gff" > id.map

# Verify map was created
if [ ! -s id.map ]; then
    echo "ERROR: Failed to create ID map"
    exit 1
fi

echo "ID map created with $(wc -l < id.map) entries"

# Copy ID map to output directory
cp id.map "$OUTPUT_DIR/"

# Apply the map to GFF and FASTAs (this modifies files in place)
echo "Mapping IDs to GFF..."
"$MAKERBIN/map_gff_ids" id.map "$gff"

echo "Mapping IDs to protein FASTA..."
"$MAKERBIN/map_fasta_ids" id.map "$protein"

echo "Mapping IDs to transcript FASTA..."
"$MAKERBIN/map_fasta_ids" id.map "$transcript"

# Copy renamed files to output directory
echo "Copying renamed files to output directory..."
cp "$gff" "$OUTPUT_DIR/"
cp "$protein" "$OUTPUT_DIR/"
cp "$transcript" "$OUTPUT_DIR/"

echo "Renaming complete!"
echo "Output files in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"

# Show a preview of the new IDs
echo ""
echo "Sample of new gene IDs:"
grep "^${prefix}" id.map | head -5
