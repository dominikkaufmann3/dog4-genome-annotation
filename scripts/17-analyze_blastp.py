
#!/usr/bin/env python3

from pathlib import Path
from statistics import mean, median
import re

WORKDIR = Path("/data/users/dkaufmann3/genome_annotation_course")
FINALDIR = WORKDIR / "output/MAKER/final"
COMPARISONS = WORKDIR / "output/comparisons"
COURSEDIR = Path("/data/courses/genome_annotation_resources/2026")

PROTEINS = FINALDIR / "assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT_BLAST = COMPARISONS / "blastp_uniprot.besthits.tsv"
TAIR_BLAST = COMPARISONS / "blastp_TAIR10.besthits.tsv"
UNIPROT_REF = COURSEDIR / "data/uniprot_viridiplantae_reviewed.fa"
GFF = FINALDIR / "assembly.all.maker.noseq.gff_iprscan_quality_filtered.gff"

FLC_REF = "AT5G10140"


def read_fasta_lengths(path):
    lengths = {}
    current = None

    with open(path) as f:
        for line in f:
            if line.startswith(">"):
                current = line[1:].split()[0]
                lengths[current] = 0
            elif current is not None:
                lengths[current] += len(line.strip())

    return lengths


def read_blast(path):
    hits = {}
    with open(path) as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            fields = line.rstrip("\n").split("\t")
            hits[fields[0]] = fields
    return hits


def summarize_lengths(label, values):
    if not values:
        print(f"{label}: no proteins")
        return

    print(
        f"{label}: n={len(values)}, "
        f"mean={mean(values):.1f} aa, "
        f"median={median(values):.1f} aa"
    )


def uniprot_descriptions(path):
    descriptions = {}
    with open(path) as f:
        for line in f:
            if not line.startswith(">"):
                continue

            header = line[1:].strip()
            identifier = header.split()[0]

            # UniProt headers typically contain OS= after description
            description = header.split(" OS=")[0]
            description = description[len(identifier):].strip()

            descriptions[identifier] = description

    return descriptions


def find_description(subject_id, descriptions):
    if subject_id in descriptions:
        return descriptions[subject_id]

    # Support UniProt accessions with or without sp|...| prefixes
    parts = subject_id.split("|")
    if len(parts) >= 2:
        accession = parts[1]
        for key, desc in descriptions.items():
            if accession in key.split("|"):
                return desc

    return None


def is_uncharacterized(description):
    return bool(re.search(
        r"uncharacterized|unknown protein|protein of unknown function|"
        r"putative protein|hypothetical protein",
        description,
        re.IGNORECASE
    ))


def main():
    lengths = read_fasta_lengths(PROTEINS)
    uniprot = read_blast(UNIPROT_BLAST)
    tair = read_blast(TAIR_BLAST)

    print("\n=== 1. UniProt BLASTP hits ===")

    total = len(lengths)
    matched = set(lengths) & set(uniprot)
    unmatched = set(lengths) - matched

    print(f"Total proteins: {total}")
    print(f"Significant hits: {len(matched)} ({100 * len(matched) / total:.2f}%)")
    print(f"No hit: {len(unmatched)} ({100 * len(unmatched) / total:.2f}%)")

    descriptions = uniprot_descriptions(UNIPROT_REF)

    characterized = 0
    uncharacterized = 0
    unresolved = 0

    for pid in matched:
        subject_id = uniprot[pid][1]
        desc = find_description(subject_id, descriptions)

        if desc is None:
            unresolved += 1
        elif is_uncharacterized(desc):
            uncharacterized += 1
        else:
            characterized += 1

    print(f"Hits to characterized/other described proteins: {characterized}")
    print(f"Hits labelled uncharacterized: {uncharacterized}")
    print(f"Descriptions not resolved: {unresolved}")

    print("\nNote: These categories use description keywords.")
    print("A described protein is not necessarily experimentally characterized.")

    print("\n=== 2. Protein length comparison ===")

    summarize_lengths(
        "With UniProt hit",
        [lengths[pid] for pid in matched]
    )
    summarize_lengths(
        "Without UniProt hit",
        [lengths[pid] for pid in unmatched]
    )

    print("\nLength differences suggest possible fragmentation,")
    print("but cannot establish protein completeness on their own.")

    print("\n=== 3. FLC identification ===")

    candidates = [
        fields for fields in tair.values()
        if FLC_REF in fields[1]
    ]

    if not candidates:
        print("No FLC best hit found.")
        return

    for fields in candidates:
        pid = fields[0]
        gene_id = re.sub(r"-R[A-Z]+$", "", pid)

        print(f"\nDog-4 protein: {pid}")
        print(f"Dog-4 gene: {gene_id}")
        print(f"TAIR10 hit: {fields[1]}")
        print(f"Identity: {fields[2]}%")
        print(f"Alignment length: {fields[3]} aa")
        print(f"E-value: {fields[10]}")
        print(f"Bit score: {fields[11]}")

        print("\nWeek 3 Pfam / GO annotations:")

        found = False
        pfam = set()
        go_terms = set()

        with open(GFF) as f:
            for line in f:
                if line.startswith("#") or gene_id not in line:
                    continue

                found = True

                for pf in re.findall(r"PF\d{5}", line):
                    pfam.add(pf)

                for go in re.findall(r"GO:\d{7}", line):
                    go_terms.add(go)

        print("Pfam:", ", ".join(sorted(pfam)) if pfam else "None found")
        print("GO:", ", ".join(sorted(go_terms)) if go_terms else "None found")

        if not found:
            print("No matching entries found in the annotated GFF.")

        if "PF00319" in pfam:
            print("PF00319 supports a MADS-box DNA-binding function.")

        print("Known reference function: FLC is a MADS-box")
        print("transcription factor that represses flowering.")


if __name__ == "__main__":
    main()

