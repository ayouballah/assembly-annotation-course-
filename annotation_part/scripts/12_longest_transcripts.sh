#!/usr/bin/env bash
#SBATCH --job-name=longest_transcripts
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/longest_transcripts_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/longest_transcripts_%j.err
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
TRANSCRIPT="$INPUTDIR/assembly.all.maker.transcripts.fasta"

# Change to input directory
cd "$INPUTDIR"

# Check if transcript file exists
if [ ! -f "$TRANSCRIPT" ]; then
    echo "ERROR: Transcript file not found: $TRANSCRIPT"
    echo "Make sure maker_rename.sh completed successfully"
    exit 1
fi

echo "Input transcript file: $TRANSCRIPT"
echo "Total transcript sequences: $(grep -c '^>' $TRANSCRIPT)"

# Index transcript FASTA with samtools
echo ""
echo "Indexing transcript FASTA..."
samtools faidx "$TRANSCRIPT"

# Extract gene ID (before "-R") and transcript length, then pick longest isoform per gene
echo "Identifying longest transcript isoform per gene..."
cut -f1,2 "${TRANSCRIPT}.fai" \
| awk 'BEGIN{FS=OFS="\t"}{id=$1; len=$2; split(id,a,"-R"); gene=a[1]; print gene,len,id}' \
| sort -t $'\t' -k1,1 -k2,2nr \
| awk -F'\t' '!seen[$1]++ {print $3}' \
> transcript_longest_ids.txt

# Verify ID list was created
if [ ! -f "transcript_longest_ids.txt" ]; then
    echo "ERROR: Failed to generate transcript ID list"
    exit 1
fi

echo "Unique genes found: $(wc -l < transcript_longest_ids.txt)"

# Extract longest transcript sequences
echo "Extracting longest transcript isoforms..."
faSomeRecords "$TRANSCRIPT" transcript_longest_ids.txt maker_transcripts.longest.fasta

# Verify output
if [ ! -f "maker_transcripts.longest.fasta" ]; then
    echo "ERROR: Failed to extract transcript sequences"
    exit 1
fi

echo ""
echo "=== Results ==="
echo "Total transcripts (all isoforms): $(grep -c '^>' $TRANSCRIPT)"
echo "Longest transcripts (one per gene): $(grep -c '^>' maker_transcripts.longest.fasta)"
echo ""
echo "Output files:"
echo "  Longest transcript IDs: $INPUTDIR/transcript_longest_ids.txt"
echo "  Longest transcript seqs: $INPUTDIR/maker_transcripts.longest.fasta"

ls -lh "$INPUTDIR"/maker_transcripts.longest.fasta "$INPUTDIR"/transcript_longest_ids.txt
