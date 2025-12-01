#!/usr/bin/env bash

#SBATCH --job-name=maker_filter
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/maker_filter_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/maker_filter_%j.err
#SBATCH --cpus-per-task=5
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Define variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
FINALDIR="$WORKDIR/results/filtered_after_aed"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# Input files
gff="$WORKDIR/results/maker_renamed/assembly.all.maker.noseq.renamed.iprscan.gff"
transcript="$WORKDIR/results/maker_renamed/assembly.all.maker.transcripts.fasta"
protein="$WORKDIR/results/maker_renamed/assembly.all.maker.proteins.fasta"

# Create output directory
mkdir -p "$FINALDIR"
cd "$FINALDIR"

# Check if input files exist
if [ ! -f "$gff" ]; then
    echo "ERROR: InterProScan GFF not found: $gff"
    exit 1
fi

if [ ! -f "$transcript" ]; then
    echo "ERROR: Transcript file not found: $transcript"
    exit 1
fi

if [ ! -f "$protein" ]; then
    echo "ERROR: Protein file not found: $protein"
    exit 1
fi

echo "Input files found:"
echo "  GFF: $gff"
echo "  Transcripts: $transcript"
echo "  Proteins: $protein"

# Count genes before filtering
echo ""
echo "=== Before Filtering ==="
echo "Total genes: $(grep -c $'\tgene\t' $gff)"
echo "Total mRNAs: $(grep -c $'\tmRNA\t' $gff)"

# ------ Filter the GFF by AED and/or Pfam (InterProScan) annotations ------
# -s flag: keeps transcripts with AED < 1 and/or Pfam domain (from iprscan)
echo ""
echo "Filtering GFF by AED score and Pfam domains..."
perl "$MAKERBIN/quality_filter.pl" -s "$gff" > assembly_iprscan_quality_filtered.gff

# ------ Keep only gene-relevant features ------
echo "Extracting gene-relevant features..."
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" \
  assembly_iprscan_quality_filtered.gff > assembly_filtered.genes.renamed.gff3

# Count genes after filtering
echo ""
echo "=== After Filtering ==="
echo "Filtered genes: $(grep -c $'\tgene\t' assembly_filtered.genes.renamed.gff3)"
echo "Filtered mRNAs: $(grep -c $'\tmRNA\t' assembly_filtered.genes.renamed.gff3)"

echo ""
echo "Feature types in filtered GFF:"
cut -f3 assembly_filtered.genes.renamed.gff3 | sort | uniq -c

# ------ Extract remaining mRNA IDs and filter transcript/protein FASTAs ------
echo ""
echo "Extracting mRNA IDs..."
grep -P "\tmRNA\t" assembly_filtered.genes.renamed.gff3 \
  | awk '{print $9}' \
  | cut -d ';' -f1 \
  | sed 's/ID=//g' \
  > list.txt

echo "mRNA IDs to keep: $(wc -l < list.txt)"

# Load required modules for faSomeRecords
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

echo ""
echo "Filtering transcript FASTA..."
faSomeRecords "$transcript" list.txt "$FINALDIR/assembly.transcripts.renamed.filtered.fasta"

echo "Filtering protein FASTA..."
faSomeRecords "$protein" list.txt "$FINALDIR/assembly.proteins.renamed.filtered.fasta"

# Verify output files
echo ""
echo "=== Output Files ==="
echo "Filtered GFF: $(wc -l < assembly_filtered.genes.renamed.gff3) lines"
echo "Filtered transcripts: $(grep -c '^>' assembly.transcripts.renamed.filtered.fasta) sequences"
echo "Filtered proteins: $(grep -c '^>' assembly.proteins.renamed.filtered.fasta) sequences"

echo ""
echo "Quality filtering complete!"
echo "Output directory: $FINALDIR"
ls -lh "$FINALDIR"
