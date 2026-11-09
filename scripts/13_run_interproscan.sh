#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"

INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"
DBDIR="$COURSEDIR/data/interproscan-5.70-102.0/data"

mkdir -p "$FINALDIR/tmp"
cd "$FINALDIR"

apptainer exec --cleanenv \
  --pwd "$FINALDIR" \
  --bind "$DBDIR":/opt/interproscan/data \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --bind "$FINALDIR/tmp":/temp \
  "$INTERPROSCAN_SIF" \
  /opt/interproscan/interproscan.sh \
    -appl Pfam \
    --disable-precalc \
    -f TSV \
    --goterms \
    --iprlookup \
    --seqtype p \
    -cpu 8 \
    -i assembly.all.maker.proteins.fasta.renamed.fasta \
    -o output.iprscan