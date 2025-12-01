#!/usr/bin/env bash
#SBATCH --job-name=genespace_prep
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_prep_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/genespace_prep_%j.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths and labels
# ---------------------------------------------------------------------------
PROJECT_DIR="/data/users/aballah/assembly_annotation_course/annotation_part"
RESULTS_DIR="$PROJECT_DIR/results"
FILTER_DIR="$RESULTS_DIR/filtered_after_aed"
RENAMED_DIR="$RESULTS_DIR/maker_renamed"
OUT_DIR="$RESULTS_DIR/genespace"
BED_DIR="$OUT_DIR/bed"
PEP_DIR="$OUT_DIR/peptide"

COURSE_DIR="/data/courses/assembly-annotation-course/CDS_annotation"
GENE_GFF_DIR="$COURSE_DIR/data/Lian_et_al/gene_gff/selected"
PROT_FASTA_DIR="$COURSE_DIR/data/Lian_et_al/protein/selected"
TAIR_DIR="$COURSE_DIR/data"

# Labels used by GeneSpace
PRIMARY_LABEL="Sf2"              # our assembly
ALTAI_LABEL="Altai_5"
ICE_LABEL="Ice_1"
KAR_LABEL="Kar_1"
TAIR_LABEL="TAIR10"

# ---------------------------------------------------------------------------
# Input files
# ---------------------------------------------------------------------------
PRIMARY_GFF="$FILTER_DIR/assembly_filtered.genes.renamed.gff3"
PRIMARY_PROT_LONGEST="$RENAMED_DIR/maker_proteins.longest.fasta"

ALTAI_GFF="$GENE_GFF_DIR/Altai-5.EVM.v3.5.ann.protein_coding_genes.gff"
ICE_GFF="$GENE_GFF_DIR/Ice-1.EVM.v3.5.ann.protein_coding_genes.gff"
KAR_GFF="$GENE_GFF_DIR/Kar-1.EVM.v3.5.ann.protein_coding_genes.gff"

ALTAI_PEPTIDE="$PROT_FASTA_DIR/Altai-5.protein.faa"
ICE_PEPTIDE="$PROT_FASTA_DIR/Ice-1.protein.faa"
KAR_PEPTIDE="$PROT_FASTA_DIR/Kar-1.protein.faa"

TAIR_BED="$TAIR_DIR/TAIR10.bed"
TAIR_PEPTIDE="$TAIR_DIR/TAIR10.fa"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
check_file() {
    local f="$1"
    if [[ ! -f "$f" ]]; then
        echo "ERROR: Required file not found: $f" >&2
        exit 1
    fi
}

make_bed() {
    local src_gff="$1"
    local dest_bed="$2"
    awk 'BEGIN{OFS="\t"}
         $0 !~ /^#/ && $3=="gene" {
             n = split($9, attrs, ";");
             gene=""
             for (i=1; i<=n; i++) {
                 split(attrs[i], kv, "=");
                 if (kv[1]=="ID" || kv[1]=="gene_id" || kv[1]=="Name") {
                     gene=kv[2];
                     break;
                 }
             }
             if (gene=="") { gene=$9; }
             print $1, $4-1, $5, gene;
         }' "$src_gff" > "$dest_bed"
}

rewrite_longest_headers() {
    local src_fasta="$1"
    local dest_fasta="$2"
    awk 'BEGIN{FS="[ \t]"; OFS=""}
         /^>/ {
             id=$1; sub(/^>/, "", id);
             gene=id; sub(/-R.*/, "", gene);
             print ">", gene;
             next;
         }
         { print }' "$src_fasta" > "$dest_fasta"
}

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
for file in \
    "$PRIMARY_GFF" "$PRIMARY_PROT_LONGEST" \
    "$ALTAI_GFF" "$ICE_GFF" "$KAR_GFF" \
    "$ALTAI_PEPTIDE" "$ICE_PEPTIDE" "$KAR_PEPTIDE" \
    "$TAIR_BED" "$TAIR_PEPTIDE"; do
    check_file "$file"
done

mkdir -p "$BED_DIR" "$PEP_DIR"

# ---------------------------------------------------------------------------
# BED files (gene positions)
# ---------------------------------------------------------------------------
echo "Generating BED files in $BED_DIR"
make_bed "$PRIMARY_GFF" "$BED_DIR/${PRIMARY_LABEL}.bed"
make_bed "$ALTAI_GFF" "$BED_DIR/${ALTAI_LABEL}.bed"
make_bed "$ICE_GFF" "$BED_DIR/${ICE_LABEL}.bed"
make_bed "$KAR_GFF" "$BED_DIR/${KAR_LABEL}.bed"
cp "$TAIR_BED" "$BED_DIR/${TAIR_LABEL}.bed"

# ---------------------------------------------------------------------------
# Peptide FASTA files
# ---------------------------------------------------------------------------
echo "Preparing peptide FASTA files in $PEP_DIR"
rewrite_longest_headers "$PRIMARY_PROT_LONGEST" "$PEP_DIR/${PRIMARY_LABEL}.fa"
cp "$ALTAI_PEPTIDE" "$PEP_DIR/${ALTAI_LABEL}.fa"
cp "$ICE_PEPTIDE" "$PEP_DIR/${ICE_LABEL}.fa"
cp "$KAR_PEPTIDE" "$PEP_DIR/${KAR_LABEL}.fa"
cp "$TAIR_PEPTIDE" "$PEP_DIR/${TAIR_LABEL}.fa"

echo "GeneSpace input preparation complete."
ls -lh "$BED_DIR" "$PEP_DIR"