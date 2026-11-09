#!/bin/bash
#SBATCH --job-name=gene_TE_circos
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/gene_TE_circos_%j.out
#SBATCH --error=logs/gene_TE_circos_%j.err

set -euo pipefail

WORKDIR="/data/users/$USER/genome_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"

cd "$WORKDIR"

apptainer exec --cleanenv \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  --pwd "$WORKDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  Rscript --vanilla scripts/16-plot_gene_TE_circos.R
