#!/usr/bin/env bash
#SBATCH --job-name=agat_stats
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/agat_stats_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/agat_stats_%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Paths
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
RESULTDIR="$WORKDIR/results"
FINALDIR="$RESULTDIR/filtered_after_aed"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/agat_1.5.1--pl5321hdfd78af_0.sif"

INPUT_GFF="$FINALDIR/assembly_filtered.genes.renamed.gff3"
OUTPUT_PREFIX="$FINALDIR/annotation.stat"

# Ensure required files exist
if [ ! -f "$INPUT_GFF" ]; then
    echo "ERROR: Filtered GFF not found: $INPUT_GFF"
    echo "Run 10_maker_filter.sh before this step."
    exit 1
fi

if [ ! -f "$CONTAINER" ]; then
    echo "ERROR: AGAT container not found: $CONTAINER"
    exit 1
fi

cd "$FINALDIR"

echo "Running AGAT statistics on: $INPUT_GFF"

apptainer exec --bind "$RESULTDIR,$FINALDIR" "$CONTAINER" \
    agat_sp_statistics.pl -i "$INPUT_GFF" -o "$OUTPUT_PREFIX"

STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "AGAT statistics failed with exit code $STATUS"
    exit $STATUS
fi

echo "AGAT statistics completed successfully."