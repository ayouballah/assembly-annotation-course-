#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem=40G
#SBATCH --time=02:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=jf_k21
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/04_jf_k21_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/04_jf_k21_%j.err

WORKDIR="/data/users/aballah/assembly_annotation_course"
ACCESSION="Sf-2"              
K=21
THREADS=8
IN="$(ls -1 ${WORKDIR}/data/${ACCESSION}/*.fastq.gz | head -n1)"
OUTDIR="${WORKDIR}/outputs/kmer_counting_k${K}"
mkdir -p "$OUTDIR"


JELLYFISH_IMAGE="/containers/apptainer/jellyfish:2.2.6--0"

# Count canonical k-mers
apptainer exec --bind /data "$JELLYFISH_IMAGE" jellyfish count \
  -m $K -s 5G -t $THREADS -C \
  <(zcat "$IN") \
  -o "${OUTDIR}/mer_counts.jf"

# Build histogram
apptainer exec --bind /data "$JELLYFISH_IMAGE" jellyfish histo \
  -t $THREADS "${OUTDIR}/mer_counts.jf" > "${OUTDIR}/mer_counts.histo"

# Quick estimate of coverage peak (ignore low-depth noise)
awk 'NR>1 && $1>=5 { if($2>max){max=$2; cov=$1} } END{print cov}' "${OUTDIR}/mer_counts.histo" \
  > "${OUTDIR}/peak.txt"

echo "Done:"
echo "  ${OUTDIR}/mer_counts.jf"
echo "  ${OUTDIR}/mer_counts.histo"
echo "  ${OUTDIR}/peak.txt"
echo "Peak k-mer coverage (ignoring low-depth noise):"
cat "${OUTDIR}/peak.txt"