% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stars.R, R/sf.R, R/raster.R, R/ncdf.R,
%   R/proxy.R, R/rasterize.R, R/xts.R, R/OpenStreetMap.R, R/cubble.R
\name{st_as_stars}
\alias{st_as_stars}
\alias{st_as_stars.list}
\alias{st_as_stars.default}
\alias{st_as_stars.stars}
\alias{st_as_stars.bbox}
\alias{st_as_stars.sf}
\alias{st_as_stars.Raster}
\alias{st_as_stars.SpatRaster}
\alias{st_as_stars.ncdfgeom}
\alias{st_as_stars.stars_proxy}
\alias{st_as_stars.data.frame}
\alias{st_as_stars.xts}
\alias{st_as_stars.OpenStreetMap}
\alias{st_as_stars.cubble_df}
\title{convert objects into a stars object}
\usage{
st_as_stars(.x, ...)

\method{st_as_stars}{list}(.x, ..., dimensions = NULL)

\method{st_as_stars}{default}(.x = NULL, ..., raster = NULL)

\method{st_as_stars}{stars}(.x, ..., curvilinear = NULL, crs = st_crs("OGC:CRS84"))

\method{st_as_stars}{bbox}(
  .x,
  ...,
  nx,
  ny,
  dx = dy,
  dy = dx,
  xlim = .x[c("xmin", "xmax")],
  ylim = .x[c("ymin", "ymax")],
  values = 0,
  n = 64800,
  pretty = FALSE,
  inside = FALSE,
  nz,
  proxy = FALSE
)

\method{st_as_stars}{sf}(.x, ..., name = attr(.x, "sf_column"))

\method{st_as_stars}{Raster}(.x, ..., att = 1, ignore_file = FALSE)

\method{st_as_stars}{SpatRaster}(
  .x,
  ...,
  ignore_file = FALSE,
  as_attributes = all(terra::is.factor(.x))
)

\method{st_as_stars}{ncdfgeom}(.x, ..., sf_geometry = NA)

\method{st_as_stars}{stars_proxy}(
  .x,
  ...,
  downsample = 0,
  url = attr(.x, "url"),
  envir = parent.frame()
)

\method{st_as_stars}{data.frame}(
  .x,
  ...,
  dims = coords,
  xy = dims[1:2],
  y_decreasing = TRUE,
  coords = 1:2
)

\method{st_as_stars}{xts}(.x, ..., dimensions, name = "attr")

\method{st_as_stars}{OpenStreetMap}(.x, ..., as_col = FALSE)

\method{st_as_stars}{cubble_df}(.x, ..., check_times = FALSE)
}
\arguments{
\item{.x}{object to convert}

\item{...}{in case \code{.x} is of class \code{bbox}, arguments passed on to 
\link{pretty}. In case \code{.x} is of class \code{nc_proxy}, arguments
passed on to \code{\link{read_ncdf}}.}

\item{dimensions}{object of class dimensions}

\item{raster}{character; the names of the dimensions that denote raster dimensions}

\item{curvilinear}{only for creating curvilinear grids: named length 2 list holding longitude and latitude matrices or stars arrays, or the names of the corresponding attributes in \code{.x}; the names of this vector should correspond to raster dimensions the matrices are associated with; see Details.}

\item{crs}{object of class \code{crs} with the coordinate reference system of the values in \code{curvilinear}; see details}

\item{nx}{integer; number of cells in x direction; see details}

\item{ny}{integer; number of cells in y direction; see details}

\item{dx}{numeric or object of class units; cell size in x direction; see details}

\item{dy}{numeric or object of class units; cell size in y direction; see details}

\item{xlim}{length 2 numeric vector with extent (min, max) in x direction}

\item{ylim}{length 2 numeric vector with extent (min, max) in y direction}

\item{values}{value(s) to populate the raster values with}

\item{n}{the (approximate) target number of grid cells}

\item{pretty}{logical; should cell coordinates have \link{pretty} values?}

\item{inside}{logical; should all cells entirely fall inside the bbox, potentially not covering it completely (\code{TRUE}), or allways cover the bbox (\code{FALSE}), or find a good approximation (\code{NA}, default)?}

\item{nz}{integer; number of cells in z direction; if missing no z-dimension is created.}

\item{proxy}{logical; should a \code{stars_proxy} object be created? (requires gdal_create binary when sf < 1.0-6)}

\item{name}{character; attribute name for array from an \code{xts} object}

\item{att}{see \link[raster:factor]{factorValues}; column in the RasterLayer's attribute table}

\item{ignore_file}{logical; if \code{TRUE}, ignore the SpatRaster object file name}

\item{as_attributes}{logical; if \code{TRUE} and \code{.x} has more than one layer, load these as separate attributes rather than as a band or time dimension (only implemented for the case where \code{ignore_file} is \code{TRUE})}

\item{sf_geometry}{sf data.frame with geometry and attributes to be added to stars object.
Must have same number of rows as timeseries instances.}

\item{downsample}{integer: if larger than 0, downsample with this rate (number of pixels to skip in every row/column); if length 2, specifies downsampling rate in x and y.}

\item{url}{character; URL of the stars endpoint where the data reside}

\item{envir}{environment to resolve objects in}

\item{dims}{the column names or indices that form the cube dimensions}

\item{xy}{the x and y raster dimension names or indices; only takes effect after dims has been specified}

\item{y_decreasing}{logical; if TRUE, (numeric) y values get a negative delta (decrease with increasing index)}

\item{coords}{same as dims, for symmetry with \link[sf]{st_as_sf}}

\item{as_col}{logical; return rgb numbers (FALSE) or (character) color values (TRUE)?}

\item{check_times}{logical; should we check that the time stamps of all time series are identical?}
}
\description{
convert objects into a stars object
}
\details{
if \code{curvilinear} is a list with \code{stars} objects with longitude and latitude values, its coordinate reference system is typically not that of the latitude and longitude values. If \code{curvilinear} contains the names of two arrays in \code{.x}, then these are removed from the returned object.

For the \code{bbox} method: if \code{pretty} is \code{TRUE}, raster cells may extend the coordinate range of \code{.x} on all sides. If in addition to \code{nx} and \code{ny}, \code{dx} and \code{dy} are also missing, these are set to a single value computed as \code{sqrt(diff(xlim)*diff(ylim)/n)}. 

If \code{nx} and \code{ny} are missing and \code{values} is a matrix, the number of columns and rows of the matrix are taken.

Otherwise, if \code{nx} and \code{ny} are missing, they are computed as the (ceiling, floor, or rounded to integer value) of the ratio of the (x or y) range divided by (dx or dy), depending on the value of \code{inside}. Positive \code{dy} will be made negative. Further named arguments (\code{...}) are passed on to \code{pretty}. If \code{dx} or \code{dy} are \code{units} objects, their value is converted to the units of \code{st_crs(.x)} (only when sf >= 1.0-7).

For the \code{ncdfgeom} method: objects are point-timeseries with optional line or polygon geometry for each timeseries specified with the \code{sf_geometry} parameter. See \pkg{ncdfgeom} for more about this NetCDF-based format for geometry and timeseries.

for the \code{xts} methods, if \code{dimensions} are provided, time has to be the first dimension.
}
\examples{
if (require(plm, quietly = TRUE)) {
  data(Produc, package = "plm")
  st_as_stars(Produc, y_decreasing = FALSE)
 data(Produc, package = "plm")
 st_as_stars(Produc, y_decreasing = FALSE)
}
}
