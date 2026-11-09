#!/bin/bash
#SBATCH --job-name=agat_stats
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=logs/agat_stats_%j.out
#SBATCH --error=logs/agat_stats_%j.err

set -euo pipefail

WORKDIR="/data/users/$USER/genome_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
FINALDIR="$WORKDIR/output/MAKER/final"
AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"

cd "$FINALDIR"

apptainer exec --cleanenv \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --pwd "$FINALDIR" \
  "$AGAT_SIF" \
  agat_sp_statistics.pl \
  --gff filtered.genes.renamed.gff3 \
  --output annotation.stat
