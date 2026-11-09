library(reshape2)
# library(hrbrthemes)
library(tidyverse)
library(data.table)


# get data from parameter

data <- "output/EDTA/assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.EDTA.RM.nonzero.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t", skip = 2)
rep_table %>% head()
# How does the data look like?

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table %>% filter(Rfam != "unknown")
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?

rep_table.m <- melt(
  rep_table,
  id.vars = c("Rname", "Rclass", "Rfam", "fam"),
  measure.vars = as.character(1:50),
  variable.name = "variable",
  value.name = "value"
)


# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam)
# NOTE: Check that all the superfamilies in your dataset are included above

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # as it is percent divergence

# Question:
# rep_table.m$age <- ??? # Calculate using the substitution rate and the formula provided in the tutorial


# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron")

ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(filename = "Plots/TE_landscape.pdf", width = 10, height = 5, useDingbats = FALSE)



# Why is it important to have this plot in Mbp instead of counts?
# Hint:
# Consider a scenario where there is a lot of small fragments of TEs due to nested insertions and deletions.
# How would that affect the plot if you used counts instead of Mbp?
#
