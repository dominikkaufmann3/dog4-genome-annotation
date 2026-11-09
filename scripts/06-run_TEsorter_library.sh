#!/bin/bash
#SBATCH --job-name=TEsorter_library
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/dkaufmann3/genome_annotation_course
OUTDIR="$WORKDIR/output/EDTA"

cd "$OUTDIR"

# Classify Copia sequences
apptainer exec -C \
  --bind "$WORKDIR" \
  --pwd "$OUTDIR" \
  "$COURSEDIR/containers/TEsorter_1.3.0.sif" \
  TEsorter Copia_sequences.fa -db rexdb-plant -p 4

# Classify Gypsy sequences
apptainer exec -C \
  --bind "$WORKDIR" \
  --pwd "$OUTDIR" \
  "$COURSEDIR/containers/TEsorter_1.3.0.sif" \
  TEsorter Gypsy_sequences.fa -db rexdb-plant -p 4

