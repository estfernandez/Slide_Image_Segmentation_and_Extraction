# load user-defined functions
source("code/plot_pathology.R")
source("code/read_pathology.R")
source("code/plot_extraction.R")
source("code/slide_segmentation.R")

# slide image ID's
id <- c(cohort = "NLST", patient.id = "NLST", slide.id = "10417")

# load reconstructed heatmap
image <- read.pathology("data/10417.Rdata", binary = FALSE, ext = "RData")

# segment the whole-slide image
slide.segmentation(image, id, path = "results", display = TRUE)
