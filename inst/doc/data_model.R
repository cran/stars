## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(collapse = TRUE)
set.seed(13579)

## ----fig.width=4.5, fig.height=4-----------------------------------------
suppressPackageStartupMessages(library(stars))
m = matrix(1:20, nrow = 5, ncol = 4)
dim(m) = c(x = 5, y = 4) # named dim
(s = st_as_stars(m))

## ------------------------------------------------------------------------
dim(s[[1]])

## ----fig.width=4.5, fig.height=4-----------------------------------------
image(s, text_values = TRUE, axes = TRUE)

## ----fig.width=4.5, fig.height=4-----------------------------------------
attr(s, "dimensions")$y$delta = -1
attr(s, "dimensions")$x$geotransform[6] = -1
attr(s, "dimensions")$y$geotransform[6] = -1
image(s, text_values = TRUE, axes = TRUE)

## ------------------------------------------------------------------------
tif = system.file("tif/L7_ETMs.tif", package = "stars")
st_dimensions(read_stars(tif))["y"]

## ------------------------------------------------------------------------
attr(s, "dimensions")$x$geotransform[c(3,5)] = 0.1
attr(s, "dimensions")$y$geotransform[c(3,5)] = 0.1
# FIXME: use image()
plot(st_as_sf(s, as_points = FALSE), axes = TRUE, nbreaks = 20)

## ------------------------------------------------------------------------
atan2(0.1, 1) * 180 / pi

## ------------------------------------------------------------------------
attr(s, "dimensions")$x$geotransform[c(3,5)] = c(0.1, 0.2)
attr(s, "dimensions")$y$geotransform[c(3,5)] = c(0.1, 0.2)
plot(st_as_sf(s, as_points = FALSE), axes = TRUE, nbreaks = 20)

## ------------------------------------------------------------------------
atan2(c(0.1, 0.2), 1) * 180 / pi

## ------------------------------------------------------------------------
x = c(0,0.5,1,2,4,5)
y = c(0.3,0.5,1,2,2.2)
r = st_as_stars(list(m = m), dimensions = st_dimensions(x = x, y = y))
r
#plot(st_as_sf(r, as_points = FALSE), axes = TRUE, nbreaks = 20)
image(x, y, m, col = sf.colors(21))
x1 = c(0.25,0.75,1.5,3,4.5)
y1 = c(0.4,0.75,1.5,2.1)
image(x1, y1, m, col = sf.colors(21))

