#!/bin/bash
#SBATCH --job-name=merge_maker
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
OUTDIR="$WORKDIR/output/MAKER"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"

mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

INDEX="assembly.maker.output/assembly_master_datastore_index.log"

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    gff3_merge -d "$INDEX" -o assembly.all.maker.gff

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    gff3_merge -n -d "$INDEX" -o assembly.all.maker.noseq.gff

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$OUTDIR/tmp":/tmp --bind "$COURSEDIR" --bind "$WORKDIR" \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    fasta_merge -d "$INDEX" -o assembly
