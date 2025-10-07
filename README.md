# assembly annotation course

A pipeline that achieves genome assembly from PacBio HiFi sequencing data.

## Overview
This project evaluates three assembly algorithms (Flye, Hifiasm, LJA) alongside transcriptome assembly (Trinity) to determine optimal strategies for genome reconstruction. 
The pipeline integrates multiple quality assessment tools to provide a comprehensive evaluation of assembly and a cross-comparison analysis.

## Methodology

### Assembly Strategies
- **Flye**: Long-read assembler optimized for repeat resolution and structural variant detection
- **Hifiasm**: HiFi-specific assembler producing highly contiguous, phased assemblies
- **LJA**: La Jolla Assembler focused on accuracy and completeness
- **Trinity**: De novo transcriptome assembler for RNA-seq comparison

### Quality Evaluation Framework
- **BUSCO**: Assesses gene space completeness using conserved single-copy orthologs
- **QUAST**: Provides comprehensive assembly statistics and structural metrics
- **Merqury**: K-mer based evaluation of assembly accuracy and genome completeness
- **MUMmer/NUCmer**: Whole-genome alignment for structural comparison and synteny analysis

## Workflow
1. **Preprocessing** (Scripts 1-4): Data download, quality control, trimming, and k-mer profiling
2. **Assembly** (Scripts 5.x): Parallel execution of assembly algorithms
3. **Assessment** (Scripts 6-7): Multi-dimensional quality evaluation
4. **Comparison** (Scripts 8-9): Structural analysis and cross-assembly comparison
