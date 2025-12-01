#!/usr/bin/env bash
#SBATCH --job-name=map_blastp_uniprot
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/map_blastp_uniprot_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/map_blastp_uniprot_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=04:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
RESULTDIR="$WORKDIR/results"
FILTERDIR="$RESULTDIR/filtered_after_aed"
BLASTDIR="$RESULTDIR/blastp_uniprot"
DB="$COURSEDIR/data/uniprot/uniprot_viridiplantae_reviewed.fa"

GFF_INPUT="$FILTERDIR/assembly_filtered.genes.renamed.gff3"
PROT_INPUT="$FILTERDIR/assembly.proteins.renamed.filtered.fasta"
BEST_HITS="$BLASTDIR/blastp_uniprot_output.besthits"

# Ensure inputs exist
missing=0
for f in "$GFF_INPUT" "$PROT_INPUT" "$BEST_HITS" "$DB"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Required file missing: $f"
        missing=1
    fi
done

if [ $missing -ne 0 ]; then
    echo "Aborting due to missing input files."
    exit 1
fi

# Ensure MAKER binaries exist
if [ ! -x "$MAKERBIN/maker_functional_fasta" ]; then
    echo "ERROR: maker_functional_fasta not found at $MAKERBIN"
    exit 1
fi

if [ ! -x "$MAKERBIN/maker_functional_gff" ]; then
    echo "ERROR: maker_functional_gff not found at $MAKERBIN"
    exit 1
fi

cd "$BLASTDIR"

echo "Copying original annotation files for UniProt mapping backup..."
cp "$PROT_INPUT" maker_proteins.filtered.fasta.Uniprot
cp "$GFF_INPUT" filtered.genes.renamed.gff3.Uniprot.gff3

echo "Annotating proteins with functional descriptions..."
"$MAKERBIN/maker_functional_fasta" "$DB" "$BEST_HITS" "$PROT_INPUT" > maker_proteins.filtered.fasta.Uniprot

if [ $? -ne 0 ]; then
    echo "ERROR: maker_functional_fasta failed"
    exit 1
fi

echo "Annotating GFF with functional descriptions..."
"$MAKERBIN/maker_functional_gff" "$DB" "$BEST_HITS" "$GFF_INPUT" > filtered.genes.renamed.gff3.Uniprot.gff3

if [ $? -ne 0 ]; then
    echo "ERROR: maker_functional_gff failed"
    exit 1
fi

echo "Functional annotation mapping complete."
ls -lh maker_proteins.filtered.fasta.Uniprot filtered.genes.renamed.gff3.Uniprot.gff3