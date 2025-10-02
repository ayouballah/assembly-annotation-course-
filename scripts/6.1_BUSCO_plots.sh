#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=Busco_plots
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/06_busco_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end


# set variables
WORKDIR="/data/users/aballah/assembly_annotation_course"
BUSCO_DIR="${WORKDIR}/outputs/busco"
OUT_DIR="${WORKDIR}/outputs/busco/all"

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

# create directory if not available
mkdir -p $OUT_DIR

# Find and copy all BUSCO summary files (since we used --auto-lineage, the lineage names will vary)
echo "Looking for BUSCO summary files..."
find $BUSCO_DIR -name "short_summary.*.txt" -exec cp {} $OUT_DIR/ \;

# List what files we found
echo "Summary files found:"
ls -la $OUT_DIR/*.txt

# generate plots using the BUSCO module's generate_plot.py
echo "Generating BUSCO plots..."
cd $OUT_DIR
generate_plot.py -wd $OUT_DIR

  