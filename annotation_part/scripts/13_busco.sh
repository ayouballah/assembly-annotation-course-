#!/usr/bin/env bash
#SBATCH --job-name=BUSCO
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/busco_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/busco_%j.err
#SBATCH --cpus-per-task=32
#SBATCH --mem=80G
#SBATCH --time=24:00:00
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

# Define directories
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
INPUTDIR="$WORKDIR/results/maker_renamed"
RESULTDIR="$WORKDIR/results"
OUTPROT="$RESULTDIR/busco_proteins"
OUTTRANSCRIPT="$RESULTDIR/busco_transcripts"

# Input files
PROTEINS="$INPUTDIR/maker_proteins.longest.fasta"
TRANSCRIPTS="$INPUTDIR/maker_transcripts.longest.fasta"

# Create output directories
mkdir -p "$OUTPROT"
mkdir -p "$OUTTRANSCRIPT"

# Check if input files exist
if [ ! -f "$PROTEINS" ]; then
    echo "ERROR: Protein file not found: $PROTEINS"
    echo "Please run 11_longest_proteins.sh first"
    exit 1
fi

if [ ! -f "$TRANSCRIPTS" ]; then
    echo "ERROR: Transcript file not found: $TRANSCRIPTS"
    echo "Please run 12_longest_transcripts.sh first"
    exit 1
fi

echo "=========================================="
echo "BUSCO Quality Assessment"
echo "=========================================="
echo "Protein file: $PROTEINS"
echo "Transcript file: $TRANSCRIPTS"
echo "Lineage: brassicales_odb10"
echo "CPUs: ${SLURM_CPUS_PER_TASK}"
echo ""

# Run BUSCO on proteins
echo "=========================================="
echo "Running BUSCO on proteins..."
echo "=========================================="
busco -i "$PROTEINS" \
      -l brassicales_odb10 \
      -o busco_proteins \
      -m proteins \
      --cpu ${SLURM_CPUS_PER_TASK} \
      --out_path "$OUTPROT"

# Check if protein BUSCO completed successfully
if [ $? -ne 0 ]; then
    echo "ERROR: BUSCO failed on proteins"
    exit 1
fi

echo ""
echo "Protein BUSCO completed successfully!"
echo ""

# Run BUSCO on transcripts
echo "=========================================="
echo "Running BUSCO on transcripts..."
echo "=========================================="
busco -i "$TRANSCRIPTS" \
      -l brassicales_odb10 \
      -o busco_transcripts \
      -m transcriptome \
      --cpu ${SLURM_CPUS_PER_TASK} \
      --out_path "$OUTTRANSCRIPT"

# Check if transcript BUSCO completed successfully
if [ $? -ne 0 ]; then
    echo "ERROR: BUSCO failed on transcripts"
    exit 1
fi

echo ""
echo "Transcript BUSCO completed successfully!"
echo ""

# Display summary results
echo "=========================================="
echo "BUSCO Results Summary"
echo "=========================================="
echo ""
echo "Protein results:"
if [ -f "$OUTPROT/busco_proteins/short_summary.specific.brassicales_odb10.busco_proteins.txt" ]; then
    grep -E "C:|S:|D:|F:|M:|n:" "$OUTPROT/busco_proteins/short_summary.specific.brassicales_odb10.busco_proteins.txt"
else
    echo "Summary file not found"
fi

echo ""
echo "Transcript results:"
if [ -f "$OUTTRANSCRIPT/busco_transcripts/short_summary.specific.brassicales_odb10.busco_transcripts.txt" ]; then
    grep -E "C:|S:|D:|F:|M:|n:" "$OUTTRANSCRIPT/busco_transcripts/short_summary.specific.brassicales_odb10.busco_transcripts.txt"
else
    echo "Summary file not found"
fi

echo ""
echo "=========================================="
echo "Output directories:"
echo "  Proteins: $OUTPROT/busco_proteins/"
echo "  Transcripts: $OUTTRANSCRIPT/busco_transcripts/"
echo "=========================================="
