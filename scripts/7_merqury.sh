#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=merqury
#SBATCH --output=../logfiles/merqury_%j.out
#SBATCH --error=../logfiles/merqury_%j.err
#SBATCH --partition=pibu_el8

MERQURY_IMAGE="/containers/apptainer/merqury_1.3.sif"

WORKDIR="/data/users/aballah/assembly_annotation_course"
OUTDIR="${WORKDIR}/outputs/merqury"
mkdir -p $OUTDIR

FLYE="$WORKDIR/outputs/flye/assembly.fasta"
HIFIASM="$WORKDIR/outputs/hifiasm/assembly.fa"
LJA="$WORKDIR/outputs/lja_assembly/assembly.fasta"
READS="$WORKDIR/data/Sf-2/ERR11437337.fastq.gz"
MERYL="$OUTDIR/meryl.meryl"
FLYERES="$OUTDIR/flye"
HIFIRES="$OUTDIR/hifiasm"
LJARES="$OUTDIR/LJA"

mkdir -p $MERYL $FLYERES $HIFIRES $LJARES

export MERQURY="/usr/local/share/merqury"

# First, create the meryl k-mer database from reads
echo "Creating meryl k-mer database..."
apptainer exec --bind /data $MERQURY_IMAGE \
 meryl count k=21 output $MERYL $READS

#run merqury
#flye
cd $FLYERES
apptainer exec --bind /data $MERQURY_IMAGE\
 merqury.sh $MERYL $FLYE eval_flye  

#hifiasm
cd $HIFIRES
apptainer exec --bind /data $MERQURY_IMAGE\
 merqury.sh $MERYL $HIFIASM eval_hifiasm  

#lja
cd $LJARES
apptainer exec --bind /data $MERQURY_IMAGE\
 merqury.sh $MERYL $LJA eval_lja  