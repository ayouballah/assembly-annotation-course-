# Assembly and Annotation Course

This repository contains bioinformatics scripts for genome and transcriptome assembly and annotation analysis.

## Overview

This project is part of an assembly and annotation course, focusing on processing sequencing data for *Arabidopsis thaliana* (Sf-2 accession). The workflow includes quality control, read trimming, genome assembly using multiple assemblers, transcriptome assembly, and quality assessment.

## Prerequisites

- Access to a SLURM-based HPC cluster (configured for `pibu_el8` partition)
- Apptainer/Singularity containers (located at `/containers/apptainer/`)
- Required modules: BUSCO/5.4.2-foss-2021a
- Input data from course directory: `/data/courses/assembly-annotation-course/raw_data/`

## Data

The project uses:
- **HiFi sequencing data**: ERR11437337.fastq.gz (PacBio HiFi reads for Sf-2)
- **RNA-seq data**: ERR754081_1/2.fastq.gz (paired-end Illumina reads)
- **Reference genome**: *Arabidopsis thaliana* TAIR10

## Directory Structure

```
.
├── scripts/          # Analysis scripts (SLURM batch jobs)
├── outputs/          # Results from analyses (gitignored except HTML)
├── data/             # Symbolic links to raw data (gitignored)
└── logfiles/         # Job logs (gitignored)
```

## Workflow

The analysis follows a sequential pipeline:

### 1. Data Download (script 1)
```bash
sbatch scripts/1_download_reads.sh
```
Creates symbolic links to course raw data.

### 2. Quality Control (script 2)
```bash
sbatch scripts/2_run_fastqc.sh
```
Runs FastQC and MultiQC on raw reads.

### 3. Read Trimming (script 3)
```bash
sbatch scripts/3_trim_seq.sh
```
Trims RNA-seq reads with fastp; generates QC report for HiFi reads.

### 4. K-mer Counting (script 4)
```bash
sbatch scripts/4_count_kmers.sh
```
Counts k-mers in the sequencing data.

### 5. Genome Assembly (scripts 5.1-5.3)
Multiple assemblers are used:

**Flye**:
```bash
sbatch scripts/5.1_flye_assembly.sh
```

**Hifiasm**:
```bash
sbatch scripts/5.2_hifiasm_assembly.sh
```

**LJA**:
```bash
sbatch scripts/5.3_LJA_assembly.sh
```

### 6. Transcriptome Assembly (scripts 5.4)
**Trinity**:
```bash
sbatch scripts/5.4.1_Trinity_assembly_container.sh
```

### 7. Assembly Quality Assessment

**BUSCO** (genome assemblies):
```bash
sbatch scripts/6_BUSCO.sh
```

**BUSCO** (transcriptome):
```bash
sbatch scripts/6_busco_trinity.sh
```

**BUSCO plots**:
```bash
sbatch scripts/6.1_BUSCO_plots.sh
```

**QUAST**:
```bash
sbatch scripts/6.2_quast.sh
```

**Merqury**:
```bash
sbatch scripts/7_merqury.sh
```

### 8. Genome Comparison

**NUCmer**:
```bash
sbatch scripts/8_nucmer.sh
```

**MUMmer**:
```bash
sbatch scripts/9_mummer.sh
```

## Output Files

Results are organized in `outputs/`:
- `fastqc/` - Quality control reports
- `trimmed_reads/` - Trimmed sequencing reads
- `flye/`, `hifiasm/`, `lja_assembly/` - Genome assemblies
- `trinity_container_results/` - Transcriptome assembly
- `busco/` - BUSCO completeness assessments
- `merqury/` - K-mer based quality metrics
- `genomes_comparison_1/` - Genome alignment plots

## Notes

- All scripts are configured for the user `aballah` with email `ayoub.ballah@students.unibe.ch`
- Working directory is set to `/data/users/aballah/assembly_annotation_course`
- Scripts use Apptainer containers for reproducibility
- Resource allocations (CPU, memory, time) are optimized for each analysis step

## Author

Ayoub Ballah (ayoub.ballah@students.unibe.ch)
