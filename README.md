# Whole-Slide Image Segmentation and Extraction

This project contains the code to process a whole-slide image by segmenting the tissue samples within the image and, subsequently, extracting the tumor regions within each tissue sample. 

## Pathology Image

The whole-slide, or pathology, image must be represented as a reconstructed heatmap and stored as a matrix. The image and, subsequently, the matrix can be either binary or non-binary, where entry within the matrix must correspond to the region key of the heatmap. Currently, a maximum of three regions are supported where they are referred to as empty (0), tumor (1), and normal (2) region. Although, the normal region cannot apply to binary images.

For the demonstration, we have included a sample tumor region heatmap which was provided by [Dr. Shidan Wang](https://github.com/sdw95927). The heatmap was generated using a [Convolution Nueral Network](https://github.com/sdw95927/pathology-images-analysis-using-CNN) on the original whole-slide image, found in the [NLST](https://cdas.cancer.gov/nlst/) cohort and available online.

## Procedural Pipeline

The tissue regions within the reconstructed heatmap are segmented and the small regions filtered out. Within each tissue sample, the tumor regions are then segmented where the smaller tumors are filtered based on the given cutoff. The holes within each tumor region and the tumor's contour are also extracted, where the contour of each tumor is represented as an enlarged polygon chain. 

Each set of objects, corresponding to a tissue sample, are exported to the given path. Furthermore, a figure of the extraction procedure can be exported. This figure shows the original image, the extracted tumor regions, and the holes within each tumor. All regions are colored by their corresponding segment and the results from all tissue samples are shown.

Note that, if there are no tissue regions present, nothing is exported nor returned but if no tumor regions are present within a tissue sample, a set of empty objects is exported and returned.

## Code and Project Organization

The `main.R` script is the only file that can be executed and contains the code to process the sample heatmap and produce the outputs which follow the naming convention 

- `<path>/<patient.id>-<slide.id>-T<tissue.id>.Rdata` for tumor objects and 
- `<path>/<patient.id>-<slide.id>.pdf` for the figure.

### Directories

- `code` - Contains the functions to process the tumor region heatmap.
- `data` - Contains the sample data.
- `results` - Directory where the extraction results are exported to.

### Functions

- `slide.segmentation` - Main function to process the sample data with the following arguments:
  - `image` - Integer Matrix, represents the reconstructed heatmap.
  - `id` - Named Integer Vector, identification for slide image with the entries `cohort`, `patient.id`, and `slide.id`.
  - `key` - Named Integer Vector, represents the heatmap regions.
  - `cutoff` - Integer, pixel count to filter out small tumor regions.
  - `binary` - Boolean, whether the image is binary.
  - `path` - String, location to save outputs to.
  - `display` - Boolean, whether to create a plot of the extraction results.

Other files in `code` directory can be used to read tumor region heatmaps and display them.

## Contact Information

[Esteban Fernández Morales](mailto:esteban.fernandezmorales@utdallas.edu), The University of Texas at Dallas, Richardson, TX
