# Genome Annotation Pipeline - Arabidopsis thaliana Sf-2

Annotation scripts for *Arabidopsis thaliana* accession **Sf-2** genome assembly.

## Pipeline Overview

### Transposable Element Annotation (1-4)
| Script | Description |
|--------|-------------|
| `1_EDTA.sh` | EDTA pipeline for TE annotation |
| `2_TEsorter.sh` | TEsorter classification of TEs |
| `3.1_LTR-RT.r` | LTR retrotransposon analysis |
| `3.2_circlize.r` | Circular genome visualization |
| `4_TEsorter2.sh` | Additional TEsorter analysis |
| `4.3_plot.div.r/sh` | TE divergence plotting |
| `parseMe.sh` / `parseRM.pl` | RepeatMasker output parsing |

### MAKER Gene Annotation (5-12)
| Script | Description |
|--------|-------------|
| `5_maker.sh` / `5.1_maker.sh` | MAKER annotation pipeline |
| `6_maker_output_prep.sh` | Process MAKER output |
| `7_maker_rename.sh` | Rename gene models |
| `8_interproscan.sh` | Functional annotation with InterProScan |
| `9_calculate_AED.sh` | Calculate AED scores |
| `10_maker_filter.sh` | Filter annotations by AED |
| `11_longest_proteins.sh` | Extract longest protein isoforms |
| `12_longest_transcripts.sh` | Extract longest transcript isoforms |

### Quality Assessment (13-14)
| Script | Description |
|--------|-------------|
| `13_busco.sh` | BUSCO completeness assessment |
| `13.1_busco_plot.sh` | Generate BUSCO plots |
| `14_agat_stats.sh` | Annotation statistics with AGAT |

### Functional Annotation (15-17)
| Script | Description |
|--------|-------------|
| `15_blastp_uniprot.sh` | BLASTP against UniProt |
| `16_map_blastp_uniprot.sh` | Map UniProt BLAST results |
| `17_blastp_tair10.sh` | BLASTP against TAIR10 |

### Comparative Genomics (18-25)
| Script | Description |
|--------|-------------|
| `18_genespace_prepare.sh` | Prepare data for GENESPACE |
| `19_orthofinder.sh` | OrthoFinder ortholog detection |
| `21_genespace_run.sh` | Run GENESPACE (container) |
| `22_genespace.R` | GENESPACE R script |
| `23_riparian_plot.sh` | Generate riparian plots |
| `24_genespace_native.sh/R` | Native R GENESPACE (alternative) |
| `25_pangenome.sh/R` | Pangenome analysis and visualization |

## Usage

Submit scripts via SLURM:
```bash
sbatch <script_name>.sh
```

## Data
- Assembly: Sf-2 (*Arabidopsis thaliana*)
- Reference genomes: TAIR10, Altai_5, Ice_1, Kar_1
