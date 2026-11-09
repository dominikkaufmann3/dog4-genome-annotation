#!/bin/bash
#SBATCH --job-name=TE_landscape
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

OUTDIR="$WORKDIR/output/EDTA/assembly.fasta.mod.EDTA.anno"

cd "$OUTDIR"

apptainer exec -C \
  --bind "$WORKDIR" \
  --bind "$COURSEDIR" \
  --pwd "$OUTDIR" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  perl "$COURSEDIR/scripts/05-parseRM.pl" \
  -i assembly.fasta.mod.EDTA.RM.nonzero.out \
  -l 50,1 -v
