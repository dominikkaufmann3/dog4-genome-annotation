
library(data.table)

workdir <- "/data/users/dkaufmann3/genome_annotation_course"
outdir <- file.path(workdir, "output/EDTA")

# 1. Read TEsorter classification files
copia <- fread(file.path(outdir,
  "Copia_sequences.fa.rexdb-plant.cls.tsv"))

gypsy <- fread(file.path(outdir,
  "Gypsy_sequences.fa.rexdb-plant.cls.tsv"))

classes <- rbindlist(list(copia, gypsy), fill = TRUE)

# Extract the library TE identifier
classes[, TE_ID := sub("#.*", "", `#TE`)]
classes <- unique(classes[, .(TE_ID, Superfamily, Clade)])

# 2. Read the EDTA GFF3 file
gff_file <- file.path(outdir,
  "assembly.fasta.mod.EDTA.TEanno.gff3")

gff <- fread(
  cmd = paste("grep -v '^#'", shQuote(gff_file)),
  sep = "\t",
  header = FALSE
)

# Extract Name and classification from GFF3 attributes
gff[, TE_ID := sub(".*(?:^|;)Name=([^;]+).*",
                   "\\1", V9, perl = TRUE)]

gff[, TE_type := sub(".*(?:^|;)classification=([^;]+).*",
                     "\\1", V9, perl = TRUE)]

# Keep only Copia and Gypsy annotations
gff <- gff[TE_type %in% c("LTR/Copia", "LTR/Gypsy")]

# 3. Match GFF3 annotations to TEsorter classifications
matched <- merge(
  gff,
  classes,
  by = "TE_ID",
  all.x = TRUE
)

# Preserve superfamily for unclassified sequences
matched[is.na(Superfamily),
        Superfamily := sub("LTR/", "", TE_type)]

matched[is.na(Clade) | Clade == "",
        Clade := "Unclassified"]

# 4. Count genomic annotations per clade
counts <- matched[
  , .(Annotations = .N),
  by = .(Superfamily, Clade)
][order(Superfamily, -Annotations)]

print(counts)

# 5. Check totals
cat("\nTotal annotations by superfamily:\n")
print(matched[, .N, by = Superfamily])

# 6. Save results
fwrite(
  counts,
  file.path(outdir, "TE_clade_abundance.tsv"),
  sep = "\t"
)

