#!/bin/bash
#SBATCH --job-name=dog4_pangenome
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026

cd "$WORKDIR"

apptainer exec --cleanenv \
    --bind /data \
    "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \
    Rscript "$WORKDIR/scripts/20-process_pangenome.R"
