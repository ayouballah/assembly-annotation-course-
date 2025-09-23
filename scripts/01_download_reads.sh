#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_samplelist
# Redirect output and error to the parent directory's 'output' folder
#SBATCH --output=../outputs/   # Standard output
#SBATCH --error=../logfiles/%x-%j.err    # Standard error
#SBATCH --partition=pibu_el8

# Create the 'data' directory if it doesn't exist
mkdir -p ../data

# Create a symbolic link inside the 'data' directory
ln -s /data/courses/assembly-annotation-course/raw_data/RNAseq_Sha ../data/
ln -s /data/courses/assembly-annotation-course/raw_data/Sf-2 ../data/