#!/usr/bin/env bash
#SBATCH --job-name=longest_proteins
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/longest_proteins_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/longest_proteins_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=00:30:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Load required modules
module load SAMtools/1.13-GCC-10.3.0
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0

# Directories
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
INPUTDIR="$WORKDIR/results/maker_renamed"
PROT="$INPUTDIR/assembly.all.maker.proteins.fasta"

# Change to input directory
cd "$INPUTDIR"

# Check if protein file exists
if [ ! -f "$PROT" ]; then
    echo "ERROR: Protein file not found: $PROT"
    echo "Make sure maker_rename.sh completed successfully"
    exit 1
fi

echo "Input protein file: $PROT"
echo "Total protein sequences: $(grep -c '^>' $PROT)"

# Index protein FASTA with samtools
echo ""
echo "Indexing protein FASTA..."
samtools faidx "$PROT"

# Extract gene ID (before "-R") and protein length, then pick longest isoform per gene
echo "Identifying longest protein isoform per gene..."
cut -f1,2 "${PROT}.fai" \
| awk 'BEGIN{FS=OFS="\t"}{id=$1; len=$2; split(id,a,"-R"); gene=a[1]; print gene,len,id}' \
| sort -t $'\t' -k1,1 -k2,2nr \
| awk -F'\t' '!seen[$1]++ {print $3}' \
> protein_longest_ids.txt

# Verify ID list was created
if [ ! -f "protein_longest_ids.txt" ]; then
    echo "ERROR: Failed to generate protein ID list"
    exit 1
fi

echo "Unique genes found: $(wc -l < protein_longest_ids.txt)"

# Extract longest protein sequences
echo "Extracting longest protein isoforms..."
faSomeRecords "$PROT" protein_longest_ids.txt maker_proteins.longest.fasta

# Verify output
if [ ! -f "maker_proteins.longest.fasta" ]; then
    echo "ERROR: Failed to extract protein sequences"
    exit 1
fi

echo ""
echo "=== Results ==="
echo "Total proteins (all isoforms): $(grep -c '^>' $PROT)"
echo "Longest proteins (one per gene): $(grep -c '^>' maker_proteins.longest.fasta)"
echo ""
echo "Output files:"
echo "  Longest protein IDs: $INPUTDIR/protein_longest_ids.txt"
echo "  Longest protein seqs: $INPUTDIR/maker_proteins.longest.fasta"

ls -lh "$INPUTDIR"/maker_proteins.longest.fasta "$INPUTDIR"/protein_longest_ids.txt
