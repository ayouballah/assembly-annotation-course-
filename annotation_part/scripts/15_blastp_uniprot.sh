#!/usr/bin/env bash
#SBATCH --job-name=blastp_uniprot
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/blastp_uniprot_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/blastp_uniprot_%j.err
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=04:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

module load BLAST+/2.15.0-gompi-2021a

WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
RESULTDIR="$WORKDIR/results"
FILTERDIR="$RESULTDIR/filtered_after_aed"
BLASTDIR="$RESULTDIR/blastp_uniprot"
QUERY_FASTA="$FILTERDIR/assembly.proteins.renamed.filtered.fasta"
DB="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"
BEST_HITS="$BLASTDIR/blastp_uniprot_output.besthits"
RAW_OUT="$BLASTDIR/blastp_uniprot.tsv"

# Create output directory
mkdir -p "$BLASTDIR"

# Validate inputs
if [ ! -f "$QUERY_FASTA" ]; then
    echo "ERROR: Query FASTA not found: $QUERY_FASTA"
    echo "Run 10_maker_filter.sh before this step."
    exit 1
fi

if [ ! -f "$DB" ]; then
    echo "ERROR: UniProt database not found: $DB"
    exit 1
fi

cd "$BLASTDIR"

echo "Running BLASTP against UniProt plant reviewed database..."
blastp \
    -query "$QUERY_FASTA" \
    -db "$DB" \
    -num_threads "$SLURM_CPUS_PER_TASK" \
    -outfmt 6 \
    -evalue 1e-5 \
    -max_target_seqs 10 \
    -out "$RAW_OUT"

if [ $? -ne 0 ]; then
    echo "ERROR: BLASTP run failed"
    exit 1
fi

if [ ! -s "$RAW_OUT" ]; then
    echo "WARNING: BLASTP output is empty"
fi

echo "Selecting best hit per query..."
LC_ALL=C sort -t $'\t' -k1,1 -k12,12nr -k11,11g "$RAW_OUT" \
    | LC_ALL=C sort -t $'\t' -u -k1,1 --merge \
    > "$BEST_HITS"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate best hit table"
    exit 1
fi

echo "BLASTP completed. Results:"
ls -lh "$RAW_OUT" "$BEST_HITS"