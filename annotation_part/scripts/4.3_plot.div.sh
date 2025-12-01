#!/bin/bash
#SBATCH --job-name=plot_TE_div
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/plot_div_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/plot_div_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end,fail

# Load R module
module load R/4.3.2-foss-2021a

# Run the simplified R script (minimal dependencies)
Rscript /data/users/aballah/assembly_annotation_course/annotation_part/scripts/4.3_plot.div_simple.r

echo "TE divergence plotting complete!"
