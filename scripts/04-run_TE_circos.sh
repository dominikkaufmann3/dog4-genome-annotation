#!/bin/bash
#SBATCH --job-name=TE_circos
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
GENOME="$WORKDIR/output/EDTA/assembly.fasta"

# Generate the FASTA index
apptainer exec -C --bind "$WORKDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  samtools faidx "$GENOME"

# Create the Circos plot
apptainer exec -C \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  Rscript --vanilla "$WORKDIR/scripts/04-plot_TE_circos.R"

