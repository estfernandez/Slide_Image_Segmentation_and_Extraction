# READ PATHOLOGY IMAGE =========================================================

# load a slide image and store as a matrix
read.pathology <- function(file, binary, ext = c("png", "rdata"), key = NULL)
{
  # modify file extension
  ext <- tolower(ext)

  # read or load slide image
  if (binary & ext == "png")
  {
    image <- read.binary(file)
  }
  else if (ext == "rdata")
  {
    load(file) # TODO: write function to read RData into object
  }
  else
  {
    stop(paste("InvalidExt:", ext, "is invalid or PNG passed is non-binary"))
  }

  # pre-process the slide image
  process.slide(image, binary, key)
}

# PROCESS SLIDE WHEN READING ===================================================

# process the given slide image, based on the specified type
process.slide <- function(image, binary, key = NULL)
{
  # forced replacements
  repl <- c(normal = 2, tumor = 1, empty = 0)

  # set default region key
  if (!binary & is.null(key))
  {
    key <- c(normal = 0, tumor = 1, empty = 2)
  }

  # throw error since key is unnecessary for binary
  else
  {
    stop("UnnecessaryKey: region key is not necessary when binary=TRUE")
  }

  # force the image to be truly binary
  if (binary)
  {
    image[image > 1] <- 1
  }

  # fix issue where the image contains full rows of "normal" pixels
  else
  {
    image <- image.sides(image, 0, 2)
  }

  # expand the image's border
  image <- image.border(image, 2, 2)

  # store image dimensions
  W <- ncol(image); L <- nrow(image)

  # map old values to default replacements
  if (!binary)
  {
    image <- repl[match(image, key)]
  }

  matrix(as.integer(image), nrow = L, ncol = W)
}

# HELPER FUNCTIONS =============================================================

# load a binary image, storing as a matrix
read.binary <- function(file)
{
  EBImage::flip(as.array(EBImage::readImage(file)))
}

# OPERATIONS ON IMAGES =========================================================

# fixes issue where image contains row(s) or column(s) full of a specified value
image.sides <- function(image, old, new)
{
  # fix image with full rows of the given value
  image[, colSums(image == old) >= nrow(image)] <- new

  # fix image with full columns of the given value
  image[rowSums(image == old) >= ncol(image), ] <- new

  # end procedure
  image
}

# appends a specified value to an image, acting as a "border"
image.border <- function(image, val, width)
{
  # vertical border
  v <- matrix(val, nrow = nrow(image), ncol = width)

  # add left-right borders
  image <- cbind(v, image, v)

  # horizontal border
  h <- matrix(val, nrow = width, ncol = ncol(image))

  # add top-bottom border
  image <- rbind(h, image, h)

  # end procedure
  image
}
