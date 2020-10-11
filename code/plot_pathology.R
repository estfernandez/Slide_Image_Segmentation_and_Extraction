# PLOT PATHOLOGY IMAGE =========================================================

# display the slide image, based on the specified type
plot.pathology <- function(image, type = c("heatmap", "segments"), custom = NULL, publication = FALSE, object = FALSE)
{
  # number of regions present
  K <- max(image)

  # empty set of scales
  scales <- list()

  # choose color palette based on type
  if (type == "heatmap")
  {
    cols <- c(0, 3, 2)
  }
  else if (type == "segments") {
    cols <- 0:K
  }

  # throw error for invalid type
  else
  {
    stop(paste("InvalidType:", type, "is not in ['heatmap', 'segments']"))
  }

  # set custom colors
  if (!is.null(custom)) {
    cols <- custom
  }

  # modify labels
  if (type == "heatmap")
  {
    labels <- c("Empty", "Tumor", "Normal")
  }

  # default labels
  else
  {
    labels <- 0:(K + 1)
  }

  # arguments to properly segment region key
  colorkey <- list(labels = list(at = seq(0.50, K + 1, 1), labels = labels))

  # modify parameters for publication
  if (publication)
  {
    # hide scales
    scales <- list(x = list(at = NULL), y = list(at = NULL))

    # hide color key
    colorkey <- FALSE
  }

  # create plot of slide
  slide <- lattice::levelplot(image, xlab = "", ylab = "",
                              scales = scales,
                              at = (0:(K + 1) - 0.1),
                              colorkey = colorkey,
                              col.regions = cols)

  # return plot
  if (object)
  {
    return(slide)
  }

  # display figure
  plot(slide)
}
