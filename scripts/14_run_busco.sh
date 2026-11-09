#!/bin/bash
#SBATCH --job-name=busco_annotation
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail

FINALDIR=/data/users/dkaufmann3/genome_annotation_course/output/MAKER/final
cd "$FINALDIR"

module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1

busco -i assembly.all.maker.proteins.fasta.renamed.longest.fasta \
  -l brassicales_odb10 \
  -o busco_proteins \
  -m proteins \
  -c 4

busco -i assembly.all.maker.transcripts.fasta.renamed.longest.fasta \
  -l brassicales_odb10 \
  -o busco_transcripts \
  -m transcriptome \
  -c 4
