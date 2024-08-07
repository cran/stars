% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transform.R
\name{st_transform}
\alias{st_transform}
\alias{st_transform.stars}
\alias{st_transform_proj.stars}
\title{transform geometries in stars objects to a new coordinate reference system, without warping}
\usage{
\method{st_transform}{stars}(x, crs, ...)

st_transform_proj.stars(x, crs, ...)
}
\arguments{
\item{x}{object of class \code{stars}, with either raster or simple feature geometries}

\item{crs}{object of class \code{crs} with target crs}

\item{...}{ignored}
}
\description{
transform geometries in stars objects to a new coordinate reference system, without warping
}
\details{
For simple feature dimensions, \link[sf]{st_transform} is called, leading to lossless transformation. For gridded spatial data, a curvilinear grid with transformed grid cell (centers) is returned, which is also lossless. To convert this to a regular grid in the new \code{CRS}, use \link{st_warp} (which is in general lossy).

If array values contain geometries and an array as a whole is of class `sfc` and 
has a non-missing CRS, array geometries are also transformed.
}
\examples{
geomatrix = system.file("tif/geomatrix.tif", package = "stars")
(x = read_stars(geomatrix))
new = st_crs('OGC:CRS84')
y = st_transform(x, new)
plot(st_transform(st_as_sfc(st_bbox(x)), new), col = NA, border = 'red')
plot(st_as_sfc(y, as_points=FALSE), col = NA, border = 'green', axes = TRUE, add = TRUE)
image(y, col = heat.colors(12), add = TRUE)
plot(st_as_sfc(y, as_points=TRUE), pch=3, cex=.5, col = 'blue', add = TRUE)
plot(st_transform(st_as_sfc(x, as_points=FALSE), new), add = TRUE)
}
\seealso{
\link{st_warp}
}
