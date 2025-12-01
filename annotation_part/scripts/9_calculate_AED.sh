#!/usr/bin/env bash

#SBATCH --job-name=calculate_AED
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/calculate_AED_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/calculate_AED_%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Define variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
FINALDIR="$WORKDIR/results/aed"
gff="$WORKDIR/results/maker_renamed/assembly.all.maker.noseq.renamed.iprscan.gff"

# Create output directory
mkdir -p "$FINALDIR"
cd "$FINALDIR"

# Check if input GFF exists
if [ ! -f "$gff" ]; then
    echo "ERROR: InterProScan-annotated GFF not found: $gff"
    echo "Make sure interproscan.sh completed successfully"
    exit 1
fi

echo "Input GFF: $gff"
echo "Number of genes: $(grep -c $'\tgene\t' $gff)"

# Calculate AED (Annotation Edit Distance) scores
echo "Calculating AED scores..."
perl "$MAKERBIN/AED_cdf_generator.pl" -b 0.025 "$gff" > assembly.all.maker.renamed.gff.AED.txt

# Check if AED calculation succeeded
if [ ! -f "assembly.all.maker.renamed.gff.AED.txt" ]; then
    echo "ERROR: AED calculation failed"
    exit 1
fi

echo "AED calculation complete!"
echo "Output file: $FINALDIR/assembly.all.maker.renamed.gff.AED.txt"

# Display AED statistics
echo ""
echo "=== AED Score Summary ==="
echo "AED values represent annotation quality (0 = perfect, 1 = poor)"
head -20 assembly.all.maker.renamed.gff.AED.txt

echo ""
echo "Total lines in AED output: $(wc -l < assembly.all.maker.renamed.gff.AED.txt)"
ls -lh assembly.all.maker.renamed.gff.AED.txt
