#!/usr/bin/env bash

#SBATCH --job-name=interproscan
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/interproscan_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/interproscan_%j.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G
#SBATCH --time=02:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Define variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
FINALDIR="$WORKDIR/results/maker_renamed"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Input files (produced by maker_rename.sh)
protein="$FINALDIR/assembly.all.maker.proteins.fasta"
gff="$FINALDIR/assembly.all.maker.noseq.gff"

# Check if input files exist
if [ ! -f "$protein" ]; then
    echo "ERROR: Protein file not found: $protein"
    echo "Make sure maker_rename.sh completed successfully"
    exit 1
fi

if [ ! -f "$gff" ]; then
    echo "ERROR: GFF file not found: $gff"
    exit 1
fi

echo "Input files found:"
echo "  Proteins: $protein"
echo "  GFF: $gff"

# Run InterProScan (PFAM domain search)
echo "Running InterProScan..."
apptainer exec \
  --bind "$COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data" \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  --bind "$SCRATCH:/temp" \
  "$COURSEDIR/containers/interproscan_latest.sif" \
  /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV \
    --goterms --iprlookup --seqtype p \
    -i "$protein" -o "$FINALDIR/output.iprscan"

# Check if InterProScan completed successfully
if [ ! -f "$FINALDIR/output.iprscan" ]; then
    echo "ERROR: InterProScan output not found"
    exit 1
fi

echo "InterProScan completed. Output: $FINALDIR/output.iprscan"
echo "Entries found: $(wc -l < $FINALDIR/output.iprscan)"

# Update GFF with InterProScan results
echo "Updating GFF with InterProScan annotations..."
"$MAKERBIN/ipr_update_gff" "$gff" "$FINALDIR/output.iprscan" > "$FINALDIR/assembly.all.maker.noseq.renamed.iprscan.gff"

echo "InterProScan annotation complete!"
echo "Output files:"
echo "  InterProScan TSV: $FINALDIR/output.iprscan"
echo "  Updated GFF: $FINALDIR/assembly.all.maker.noseq.renamed.iprscan.gff"

ls -lh "$FINALDIR"/*.iprscan*
