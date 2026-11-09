
library(GENESPACE)

wd <- "/data/users/dkaufmann3/genome_annotation_course/output/comparisons/GENESPACE"
focal_genome <- "Dog_4"

load(file.path(wd, "results", "gsParams.rda"))

outdir <- file.path(wd, "processed_riparian")
dir.create(outdir, showWarnings = FALSE)

# 1. Dog-4 vs TAIR10, scaffolds ordered by synteny
plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  pdfFile = file.path(outdir, "Dog_4_vs_TAIR10.pdf")
)

# 2. Dog-4 vs TAIR10 with selected scaffold orientation reversed
# Example: contig_18 has a reverse-oriented syntenic block.
# This is a display adjustment, not evidence of a biological inversion.
flips <- data.frame(
  genome = focal_genome,
  chr = "contig_18"
)

plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  pdfFile = file.path(outdir, "Dog_4_vs_TAIR10_oriented.pdf")
)

# 3. All five genomes
plot_riparian(
  gsParam,
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  scalePlotWidth = 1.5,
  pdfFile = file.path(outdir, "all_genomes_TAIR10.pdf")
)

