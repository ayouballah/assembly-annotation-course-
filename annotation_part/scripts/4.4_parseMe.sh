#!/bin/bash
#SBATCH --job-name=parseRM 
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00 
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/parseRM_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/parseRM_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=begin,end,fail

# User-editable variables
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part"
OUTDIR="$WORKDIR/results/parseRM"
PARSERM_SCRIPT="$WORKDIR/scripts/parseRM.pl"

# RepeatMasker Output File
RM_FILE="$WORKDIR/results/EDTA_annotation/assembly.fa.mod.EDTA.anno/assembly.fa.mod.out"

# Create output directory
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Load BioPerl Module (required for parseRM.pl)
module load BioPerl/1.7.8-GCCcore-10.3.0

# Download parseRM.pl if it doesn't exist
if [ ! -f "$PARSERM_SCRIPT" ]; then
    echo "parseRM.pl not found. Downloading from GitHub..."
    wget -q -O "$PARSERM_SCRIPT" https://raw.githubusercontent.com/4ureliek/Parsing-RepeatMasker-Outputs/master/parseRM.pl
    chmod +x "$PARSERM_SCRIPT"
    if [ $? -eq 0 ]; then
        echo "parseRM.pl downloaded successfully!"
    else
        echo "ERROR: Failed to download parseRM.pl"
        exit 1
    fi
fi

# Verify input file exists before running
if [ ! -f "$RM_FILE" ]; then
    echo "ERROR: RepeatMasker output file not found: $RM_FILE"
    exit 1
fi

# Parse the RepeatMasker Output
perl "$PARSERM_SCRIPT" -i "$RM_FILE" -l "50,1" -v

# Check if parsing succeeded
if [ $? -eq 0 ]; then
    echo "RepeatMasker parsing complete. Results in: $OUTDIR"
else
    echo "ERROR: parseRM.pl failed with exit code $?"
    exit 1
fi