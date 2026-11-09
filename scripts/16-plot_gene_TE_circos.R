library(circlize)
library(data.table)

workdir <- "/data/users/dkaufmann3/genome_annotation_course"

gff_file <- file.path(
  workdir,
  "output/EDTA/assembly.fasta.mod.EDTA.TEanno.gff3"
)

gff <- fread(
  cmd = paste("grep -v '^#'", shQuote(gff_file)),
  sep = "\t",
  header = FALSE
)

# Read scaffold lengths from FASTA index
fai <- fread(file.path(workdir, "output/EDTA/assembly.fasta.fai"),
             header = FALSE)

# Select the 10 largest scaffolds
fai <- fai[order(-V2)][1:min(10, .N)]
scaffolds <- fai$V1

# Extract TE categories
gff[, category := fifelse(
  grepl("Gypsy", V9, ignore.case = TRUE), "Gypsy",
  fifelse(grepl("Copia", V9, ignore.case = TRUE), "Copia",
          fifelse(grepl("TIR|Mutator|CACTA|Harbinger|Mariner|hAT", V9,
                       ignore.case = TRUE), "TIR", "Other"))
)]

gff <- gff[V1 %in% scaffolds & category != "Other"]

ideogram <- data.frame(
  chr = fai$V1,
  start = 0,
  end = fai$V2
)

pdf(file.path(workdir, "output/Gene_TE_circos.pdf"), width = 10, height = 10)

circos.clear()
circos.par(start.degree = 90, gap.degree = 3)
circos.genomicInitialize(ideogram)

for (te in c("Gypsy", "Copia", "TIR")) {
  x <- gff[category == te, .(V1, V4, V5)]
  setnames(x, c("chr", "start", "end"))

  circos.genomicDensity(
    x, window.size = 100000,
    col = switch(te,
                 Gypsy = "#D55E00",
                 Copia = "#0072B2",
                 TIR = "#009E73"),
    track.height = 0.15
  )
}

# Read filtered MAKER gene annotations
gene_file <- file.path(
  workdir,
  "output/MAKER/final/filtered.genes.renamed.gff3"
)

genes <- fread(
  cmd = paste("grep -v '^#'", shQuote(gene_file)),
  sep = "\t",
  header = FALSE
)

# Retain gene features on the same 10 scaffolds
genes <- genes[V3 == "gene" & V1 %in% scaffolds]

gene_positions <- genes[, .(
  chr = V1,
  start = as.numeric(V4),
  end = as.numeric(V5)
)]

# Add gene density as a fourth track
circos.genomicDensity(
  gene_positions,
  window.size = 100000,
  col = "#7B3294",
  track.height = 0.15
)

legend(
  "center",
  legend = c("Gypsy", "Copia", "TIR", "Genes"),
  fill = c("#D55E00", "#0072B2", "#009E73", "#7B3294"),
  bty = "n"
)

dev.off()

