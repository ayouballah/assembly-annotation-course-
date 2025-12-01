#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Busco_plots
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/busco_plot_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/busco_plot_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Set variables
WORKDIR="/data/users/aballah/assembly_annotation_course"
ANNOTATION_BUSCO="${WORKDIR}/annotation_part/results"
ASSEMBLY_BUSCO="${WORKDIR}/outputs/busco"
OUT_DIR="${WORKDIR}/annotation_part/results/busco_summaries"

# Load modules
module load BUSCO/5.4.2-foss-2021a
module load R/4.3.2-foss-2021a

# Create directory
mkdir -p $OUT_DIR

# Find and copy BUSCO summary files from annotation (proteins & transcripts)
echo "Looking for annotation BUSCO summary files..."
find $ANNOTATION_BUSCO -name "short_summary.specific.*.txt" -exec cp {} $OUT_DIR/ \;

# Find and copy BUSCO summary files from genome assembly (hifiasm)
echo "Looking for genome assembly BUSCO summary files..."
find $ASSEMBLY_BUSCO/hifiasm -name "short_summary.*.txt" -exec cp {} $OUT_DIR/ \;

# Optional: also include other assemblies if you want to compare
# find $ASSEMBLY_BUSCO/flye -name "short_summary.*.txt" -exec cp {} $OUT_DIR/ \;
# find $ASSEMBLY_BUSCO/lja -name "short_summary.*.txt" -exec cp {} $OUT_DIR/ \;

# List what files we found
echo "Summary files found:"
ls -la $OUT_DIR/*.txt

# Generate plots
echo "Generating BUSCO comparison plots..."
cd $OUT_DIR
generate_plot.py -wd $OUT_DIR

echo "BUSCO plots generated in: $OUT_DIR"
echo "Check for busco_figure.png"
