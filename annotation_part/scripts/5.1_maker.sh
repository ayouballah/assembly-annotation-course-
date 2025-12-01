#!/bin/bash
#SBATCH --job-name=MPI
#SBATCH --partition=pibu_el8 
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --time=7-00:00:00
#SBATCH --ntasks-per-node=50
#SBATCH --output=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/MAKER_MPI_%j.out
#SBATCH --error=/data/users/aballah/assembly_annotation_course/annotation_part/logfiles/MAKER_MPI_%j.err    
#SBATCH --mail-user=ayoub.ballah@students.unibe.ch
#SBATCH --mail-type=end

#directories
WORKDIR="/data/users/aballah/assembly_annotation_course/annotation_part/results/MAKER_control" 

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
OUTPUT_DIR="/data/users/aballah/assembly_annotation_course/annotation_part/results/MAKER_MPI"

#make output dir path if the path doesnt exist
mkdir -p "${OUTPUT_DIR}"

#change into outputdir path
cd ${OUTPUT_DIR}

REPEATMASKER_DIR="/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

export PATH=$PATH:"/data/courses/assembly-annotation-course/CDS_annotation/softwares/RepeatMasker"

#load modules
module load OpenMPI/4.1.1-GCC-10.3.0
module load AUGUSTUS/3.4.0-foss-2021a

mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $SCRATCH:/TMP --bind $COURSEDIR --bind /data --bind $AUGUSTUS_CONFIG_PATH --bind $REPEATMASKER_DIR \
    ${COURSEDIR}/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP ${WORKDIR}/maker_opts.ctl ${WORKDIR}/maker_bopts.ctl ${WORKDIR}/maker_evm.ctl ${WORKDIR}/maker_exe.ctl
