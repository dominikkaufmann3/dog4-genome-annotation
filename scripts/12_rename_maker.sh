#!/bin/bash
#SBATCH --job-name=rename_maker
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
FINALDIR="$WORKDIR/output/MAKER/final"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"

cd "$FINALDIR"

apptainer exec --cleanenv \
  --bind "$WORKDIR" --bind "$COURSEDIR" \
  --pwd "$FINALDIR" "$MAKER_SIF" \
  bash -c '
    set -e

    maker_map_ids --prefix DOG --justify 7 \
      assembly.all.maker.noseq.gff.renamed.gff \
      > maker_id_map.txt

    map_gff_ids maker_id_map.txt \
      assembly.all.maker.noseq.gff.renamed.gff

    map_fasta_ids maker_id_map.txt \
      assembly.all.maker.proteins.fasta.renamed.fasta

    map_fasta_ids maker_id_map.txt \
      assembly.all.maker.transcripts.fasta.renamed.fasta
  '
