# PLOT EXTRACTION RESULTS ======================================================

# plot the extraction results from slide segmentation procedure
plot.extraction <- function(image, results)
{
  # merge objects
  tumors <- Reduce("+", lapply(results, `[[`, "tumors"))
  holes <- Reduce("+", lapply(results, `[[`, "holes"))

  # create figure
  figs <- c("Tumors" = plot.pathology(tumors, type = "segments", object = TRUE),
            "Holes" = plot.pathology(holes, type = "segments", object = TRUE),
            "Reconstructed Heatmap" = plot.pathology(image, type = "heatmap", object = TRUE))

  # display plot
  plot(figs)
}
