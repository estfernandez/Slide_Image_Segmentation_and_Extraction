# PLOT EXTRACTION RESULTS ======================================================

# plot the extraction results from slide segmenation procedure
plot.extraction <- function(image, objects)
{
  # tumor regions
  tumors <- Reduce("+", lapply(objects, `[[`, "tumors"))

  # holes within tumors
  holes <- Reduce("+", lapply(objects, `[[`, "holes"))

  # create figure
  c(
    "Tumors" = plot.pathology(tumors - holes, type = "segments", object = TRUE),
    "Holes" = plot.pathology(holes, type = "segments", object = TRUE),
    "Reconstructed Heatmap" = plot.pathology(image, type = "heatmap", object = TRUE)
  )
}
