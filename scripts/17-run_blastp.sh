#!/bin/bash
#SBATCH --job-name=dog4_blastp
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
set -euo pipefail
WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
TAIR10="$COURSEDIR/data/TAIR10_pep_20110103_representative_gene_model"
OUTDIR="$WORKDIR/output/comparisons"
mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"
module load BLAST+/2.15.0-gompi-2021a
blastp -query "$PROTEINS" -db "$UNIPROT" -num_threads 10 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out "$OUTDIR/blastp_uniprot.tsv" &
uniprot_job=$!
blastp -query "$PROTEINS" -db "$TAIR10" -num_threads 10 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out "$OUTDIR/blastp_TAIR10.tsv" &
tair_job=$!
wait "$uniprot_job"
wait "$tair_job"
for reference in uniprot TAIR10; do
  sort -k1,1 -k12,12gr -k11,11g "$OUTDIR/blastp_${reference}.tsv" | awk -F '\t' '!seen[$1]++' > "$OUTDIR/blastp_${reference}.besthits.tsv"
done
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
apptainer exec --cleanenv --env TMPDIR=/tmp --bind /data --bind "$WORKDIR" --bind "$OUTDIR/tmp":/tmp --pwd "$OUTDIR" "$MAKER_SIF" maker_functional_fasta "$UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$PROTEINS" > "$OUTDIR/maker_proteins.filtered.Uniprot.fasta"
apptainer exec --cleanenv --env TMPDIR=/tmp --bind /data --bind "$WORKDIR" --bind "$OUTDIR/tmp":/tmp --pwd "$OUTDIR" "$MAKER_SIF" maker_functional_gff "$UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$GENES" > "$OUTDIR/filtered.genes.Uniprot.gff3"
echo 'BLASTP and UniProt annotation completed'
