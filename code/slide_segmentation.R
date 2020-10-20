# WHOLE-SLIDE IMAGE SEGMENTATION & EXTRACTION ==================================

# segment and extract a whole-slide image
slide.segmentation <- function(image, id, key = NULL, cutoff = 150, binary = FALSE, path = ".", display = FALSE)
{
  # default region key
  if (is.null(key))
  {
    if (binary)
    {
      key <- c(empty = 0, tumor = 1, normal = 0)
    }
    else
    {
      key <- c(empty = 0, tumor = 1, normal = 2)
    }
  }

  # filename for exports
  file <- paste0(path, "/", id["patient.id"], "-", id["slide.id"])

  # segment tissue samples
  tissues <- segment.tissues(image, empty = key["empty"])

  # number of samples
  K <- length(tissues)

  # tumor segmentation and export
  if (K > 0)
  {
    # extract objects
    res <- lapply(1:K, function(i)
    {
      # modify ID's
      current <- c(id, tissue.id = i)

      # tumor extraction
      objs <- extract.tumors(tissues[[i]], cutoff = cutoff,
                             empty = key["empty"],
                             tumor = key["tumor"],
                             normal = key["normal"])

      # merge objects and ID's
      objs <- c(objs, id = list(current))

      # export items separately
      save.list(objs, file = paste0(file, "-T", i, ".Rdata"))

      # end procedure
      objs
    }
    )

    # display results
    if (display)
    {
      # create PDF file
      pdf(file = paste0(file, ".pdf"))

      # plot results
      print(plot.extraction(image, res))

      # close file
      dev.off()
    }

    # end procedure
    res
  }
}

# TISSUE SEGMENTATION PROCEDURE ================================================

# segment tissue samples
segment.tissues <- function(image, empty = 0, cutoff = NULL)
{
  # binary mask for tissue regions
  E <- EBImage::fillHull(image != empty)

  # segment and filter samples
  E <- filter.segments(EBImage::bwlabel(E), cutoff = cutoff, nomatch = empty)

  # number of samples
  K <- max(E)

  # list to store samples
  samples <- vector("list", length = K)

  # create list of tissue samples from original image
  if (K > 0)
  {
    for (i in 1:K)
    {
      samples[[i]] <- image * (E == i)
    }
  }

  samples
}

# TUMOR EXTRACTION PROCEDURE ===================================================

# extract tumor representations
extract.tumors <- function(image, empty = 0, tumor = 1, normal = 2, cutoff = NULL)
{
  # binary mask for tumor regions
  E <- EBImage::fillHull(image == tumor)

  # segment and filter the tumors
  tumors <- filter.segments(EBImage::bwlabel(E), cutoff = cutoff, nomatch = empty)

  # holes within tumors
  holes <- tumors * (image == normal)

  # extract polygon chain from tumors
  polygon.chain <- create.polygon.chain(tumors, k = 3)

  # create list of objects
  list(holes = holes, tumors = tumors - holes, polygon.chain = polygon.chain)
}

# OPERATIONS ON IMAGES =========================================================

# filter the regions in a segmented matrix, based on the specified pixel cutoff
filter.segments <- function(image, cutoff = NULL, nomatch = 0)
{
  # pixel count for regions
  pixels <- table(image)

  # codes for regions
  labels <- names(pixels)

  # filter out zero-index
  if (labels[1] == "0")
  {
    pixels <- pixels[-1]; labels <- labels[-1]
  }

  # compute pixel cutoff
  if (is.null(cutoff))
  {
    cutoff <- max(pixels) / 2
  }

  # find "islands" (small regions)
  islands <- labels[pixels < cutoff]

  # filter out islands
  keep <- pixels[!(labels %in% islands)]

  # sort kept regions
  keep <- sort(keep, decreasing = TRUE)

  # re-map regions kept from largest to smallest
  matrix(match(image, names(keep), nomatch), nrow(image), ncol(image))
}

# enlarge the image by a specified constant
image.enlarge <- function(image, k)
{
  # obtain dimensions of the image
  rows <- dim(image)[1]; cols <- dim(image)[2]

  # create enlarged image matrix
  enlarged <- matrix(0, nrow = k * rows, ncol = k * cols)

  # populate matrix from original image
  for (i in 1:rows)
  {
    for (j in 1:cols)
    {
      for (ii in (k*(i - 1) + 1):(k*i))
      {
        for (jj in (k*(j - 1) + 1):(k*j))
        {
          enlarged[ii, jj] <- image[i, j];
        }
      }
    }
  }

  enlarged
}

# CREATE POLYGON CHAIN =========================================================

# extract the closed polygon chain from a set of regions in a segmented matrix
create.polygon.chain <- function(image, k = 3)
{
  # enlarge image by specified constant
  image <- image.enlarge(image, k = k)

  # extract polygon chain for each region
  polygon.chain <- EBImage::ocontour(image)

  # validate and process polygon chain
  lapply(polygon.chain, function(P)
  {
    # find duplicated entries
    dups <- duplicated(P)

    # check if no duplicates
    if (sum(dups) > 0)
    {
      stop("NonPolygon: a boundary could not be formed into a polygon chain")
    }

    # obtain starting point
    P1 <- sequence.starting.point(P)

    # shift the points
    if (P1 > 1)
    {
      P <- shift.sequence(P, P1, closed = FALSE)
    }

    # close off chain
    rbind(P, P[1, ])
  })
}

# find the starting point of a sequence of points i.e. lowest left-most point
sequence.starting.point <- function(P)
{
  # minimum y-coordinate
  y.min <- min(P[, 2])

  # coordinates with lowest y-values
  P1 <- P[P[, 2] == y.min, ]

  # check if only one point
  if (!is.null(dim(P1)))
  {
    # minimum x-coordinate from set
    x.min <- min(P1[, 1])

    # starting boundary point
    P1 <- P1[P1[, 1] == x.min, ];
  }

  # index of starting point
  which(P[, 1] == P1[1] & P[, 2] == P1[2])
}

# shift sequence of points based on index
shift.sequence <- function(P, n, closed = TRUE)
{
  # open polygon chain
  if (closed)
  {
    P <- P[-nrow(P), ]
  }

  # location shifts
  index <- magic::shift(1:nrow(P), i = 1 - n)

  # create shifted polygon chain
  P <- P[index, ]

  # close polygon chain
  if (closed)
  {
    P <- rbind(P, P[1, ])
  }

  # end procedure
  P
}

# HELPER FUNCTIONS =============================================================

# export objects in a list, separately
save.list <- function(objs, file)
{
  # store objects as an environment
  env <- as.environment(objs)

  # store names
  n <- as.list(names(objs))

  # export objects
  do.call(save, c(n, list(file = file, envir = env)))
}
