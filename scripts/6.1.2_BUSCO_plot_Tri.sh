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


# Set variables
WORKDIR="/data/users/aballah/assembly_annotation_course"
OUT_DIR="${WORKDIR}/outputs/busco/Trinity_comparison"

# Load BUSCO module
module load BUSCO/5.4.2-foss-2021a

# Create output directory and copy Trinity BUSCO summary files
mkdir -p $OUT_DIR
find ${WORKDIR}/outputs/busco/trinity_container ${WORKDIR}/outputs/busco/trinity_module \
     -name "short_summary.*.txt" -exec cp {} $OUT_DIR/ \;

# Generate comparison plots
cd $OUT_DIR
generate_plot.py -wd $OUT_DIR

  