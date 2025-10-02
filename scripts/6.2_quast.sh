#!/bin/bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=quast
#SBATCH --output=/data/users/aballah/assembly_annotation_course/logfiles/06_quast_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/logfiles/06_quast_%j.err
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=error,end

# set variables
WORKDIR="/data/users/aballah/assembly_annotation_course"
QUAST_IMAGE=/containers/apptainer/quast_5.2.0.sif
OUTDIR=${WORKDIR}/outputs/quast

# Assembly file paths
HIFIASM=${WORKDIR}/outputs/hifiasm/assembly.fa
LJA=${WORKDIR}/outputs/lja_assembly/assembly.fasta  
FLYE=${WORKDIR}/outputs/flye/assembly.fasta

# Reference files
REF="${WORKDIR}/data/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
REF_FEATURE="${WORKDIR}/data/references/TAIR10_GFF3_genes.gff"

# Create output directory
mkdir -p $OUTDIR




# run quast
# -o <output_dir>: output directory
# -r <path>: reference genome file. Optional. Many metrics can't be evaluated without a reference. If this is omitted, QUAST will only report the metrics that can be evaluated without a reference.
# --features (or -g) <path>: file with genomic feature positions in the reference genome
# --threads (or -t) <int>: maximum number of threads. The default value is 25% of all available CPUs but not less than 1
# -L: take assembly names from their parent directory names
# --eukaryote (or -e): genome is eukaryotic. Affects gene finding, conserved orthologs finding and contig alignment
# --large: genome is large (typically > 100 Mbp). Use optimal parameters for evaluation of large genomes. Affects speed and accuracy. In particular, imposes --eukaryote --min-contig 3000 --min-alignment 500 --extensive-mis-size 7000
# --est-ref-size <int>: estimated reference genome size (in bp) for computing NGx statistics. This value will be used only if a reference genome file is not specified
# --pacbio <path>: file with PacBio SMRT reads in FASTQ format (files compressed with gzip are allowed)
# --no-sv: do not run structural variant calling and processing (make sense only if reads are specified)
# --labels (or -l) <label,label...>: Human-readable assembly names. Those names will be used in reports, plots and logs.


# With reference
apptainer exec --bind /data ${QUAST_IMAGE} \
  quast.py -o ${OUTDIR}/with_ref \
  --labels flye,hifiasm,LJA \
  -r $REF \
  --features $REF_FEATURE \
  --threads $SLURM_CPUS_PER_TASK \
  --eukaryote \
  $FLYE $HIFIASM $LJA

# Without reference  
apptainer exec --bind /data ${QUAST_IMAGE} \
  quast.py -o ${OUTDIR}/no_ref \
  --labels flye,hifiasm,LJA \
  --threads $SLURM_CPUS_PER_TASK \
  --eukaryote \
  --est-ref-size 130000000 \
  $FLYE $HIFIASM $LJA