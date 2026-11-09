#!/bin/bash
#SBATCH --job-name=LTR_plots
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/dkaufmann3/genome_annotation_course
OUTDIR="$WORKDIR/output/LTR_full_length"

cd "$OUTDIR"

apptainer exec -C \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  --pwd "$OUTDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  Rscript --vanilla "$COURSEDIR/scripts/03-full_length_LTRs_identity_copy.R"
