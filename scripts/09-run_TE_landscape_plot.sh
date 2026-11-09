#!/bin/bash
#SBATCH --job-name=TE_landscape_plot
#SBATCH --partition=pibu_el8
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026

cd "$WORKDIR"
mkdir -p Plots

apptainer exec -C \
  --bind "$WORKDIR" \
  --pwd "$WORKDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  Rscript --vanilla scripts/09-plot_TE_landscape.R
