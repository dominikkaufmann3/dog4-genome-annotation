#!/bin/bash
#SBATCH --job-name=extract_Copia_Gypsy
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/dkaufmann3/genome_annotation_course

cd "$WORKDIR/output/EDTA"

apptainer exec -C \
  --bind "$WORKDIR" \
  --pwd "$WORKDIR/output/EDTA" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  seqkit grep -r -p "Copia" \
  assembly.fasta.mod.EDTA.TElib.fa > Copia_sequences.fa

apptainer exec -C \
  --bind "$WORKDIR" \
  --pwd "$WORKDIR/output/EDTA" \
  "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
  seqkit grep -r -p "Gypsy" \
  assembly.fasta.mod.EDTA.TElib.fa > Gypsy_sequences.fa
