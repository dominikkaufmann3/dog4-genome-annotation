#!/bin/bash
set -euo pipefail

WORKDIR=/data/users/dkaufmann3/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026

ACCESSION=Dog_4
FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.longest.fasta"

GENESPACE_DIR="$WORKDIR/output/comparisons/GENESPACE"

mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"

# 1. Prepare Dog-4 gene coordinates
awk 'BEGIN{FS=OFS="\t"}
$3=="gene" {
    n=split($9,a,";")
    id=""
    for(i=1;i<=n;i++)
        if(a[i]~/^ID=/){id=substr(a[i],4);break}
    if(id!="") print $1,$4-1,$5,id
}' "$GENES" > "$GENESPACE_DIR/bed/${ACCESSION}.bed"

# 2. Prepare Dog-4 longest-isoform proteins
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" |
    sed '/^>/s/-R[A-Z]*$//' \
    > "$GENESPACE_DIR/peptide/${ACCESSION}.fa"

# 3. Copy TAIR10 reference
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/"
cp "$COURSEDIR/data/TAIR10.fa" "$GENESPACE_DIR/peptide/"

# 4. Copy three additional Arabidopsis accessions
SOURCE="$COURSEDIR/data/Lian_et_al/GENESPACE"

for acc in Altai_5 Etna_2 Ice_1; do
    cp "$SOURCE/bed/${acc}.bed" "$GENESPACE_DIR/bed/"
    cp "$SOURCE/peptide/${acc}.fa" "$GENESPACE_DIR/peptide/"
done

# 5. Display input counts
echo "GENESPACE input summary:"
for acc in Dog_4 TAIR10 Altai_5 Etna_2 Ice_1; do
    bed="$GENESPACE_DIR/bed/${acc}.bed"
    fa="$GENESPACE_DIR/peptide/${acc}.fa"

    genes=$(wc -l < "$bed")
    proteins=$(grep -c '^>' "$fa" || true)

    printf '%-10s Genes: %-8s Proteins: %s\n' "$acc" "$genes" "$proteins"
done

echo "Preparation complete."