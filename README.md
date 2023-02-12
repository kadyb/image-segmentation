# Image segmentation in R

In this repository you will find examples of image segmentation scripts in R.
Example `ortho.R` shows segmentation on a small RGB orthoimage, while example
`landsat.R` uses a multiband spectral image (8261 x 8201 pixels x 7 bands).
The Quarto file `comparison.qmd` contains a comparison of the simple kmeans
clustering algorithm with [supercells](https://github.com/Nowosad/supercells)
based on SLIC algorithm.

Note: Currently the kmeans prediction method in `landsat.R` is very slow
(calculations take ~1 hour). Alternatively, you can check out the example
in `landsat_blocks.R`, which uses processing in blocks (it takes ~18 min),
but unfortunately the boundaries between blocks are strongly visible.

![segmentation](https://user-images.githubusercontent.com/35004826/217364937-4e9e5c14-a71b-4601-9de5-8791b777d50b.png)
