# convert arrays to data.frame, in long form
to_df = function(x) {
	as.data.frame(lapply(x, function(y) structure(y, dim = NULL)), stringsAsFactors = FALSE)
}

set_dim = function(x, d) {
	lapply(x, function(y, dims) structure(y, dim = dims), dims = d)
}

get_dims = function(d_cube, d_stars) {
	xy = attr(d_stars, "raster")$dimensions
	d_stars = d_stars[names(d_cube)]
	for (i in seq_along(d_cube)) {
		d_stars[[i]]$values = if (inherits(d_stars[[i]]$values, "intervals")) {
				v = d_stars[[i]]$values
				d_stars[[i]]$values = v[ na.omit(find_interval(d_cube[[i]], v)) ]
			} else if (is.list(d_stars[[i]]$values)) {
				d_stars[[i]]$values[ d_cube[[i]] ]
			} else
				d_cube[[i]]
		d_stars[[i]] = create_dimension(values = d_stars[[i]]$values, point = d_stars[[i]]$point, 
			refsys = d_stars[[i]]$refsys, is_raster = names(d_stars)[i] %in% xy)
	}
	d_stars
}

#' dplyr verbs for stars objects
#' 
#' dplyr verbs for stars objects; package dplyr needs to be loaded before these methods can be used for stars objects.
#' @param .data object of class \code{stars}
#' @param ... see \link[dplyr]{filter}
#' @name dplyr
filter.stars <- function(.data, ...) {
    if (!requireNamespace("dplyr", quietly = TRUE))
        stop("package dplyr required, please install it first") # nocov
    if (!requireNamespace("cubelyr", quietly = TRUE))
        stop("package cubelyr required, please install it first") # nocov
	cb = cubelyr::as.tbl_cube(.data)
	cb = dplyr::filter(cb, ...)
	st_as_stars(cb$mets, dimensions = get_dims(cb$dims, st_dimensions(.data)))
}

#' @name dplyr
filter.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "filter", ".data", env = environment())
}


#' @name dplyr
mutate.stars <- function(.data, ...) {
	ret = dplyr::mutate(to_df(.data), ...)
	st_as_stars(set_dim(ret, dim(.data)), dimensions = st_dimensions(.data))
}

#' @name dplyr
mutate.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "mutate", ".data", env = environment())
}

#' @name dplyr
transmute.stars <- function(.data, ...) {
	ret = dplyr::transmute(to_df(.data), ...)
	st_as_stars(set_dim(ret, dim(.data)), dimensions = st_dimensions(.data))
}

#' @name dplyr
transmute.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "transmute", ".data", env = environment())
}


#' @name dplyr
select.stars <- function(.data, ...) {
    if (!requireNamespace("dplyr", quietly = TRUE))
        stop("package dplyr required, please install it first") # nocov
    ret <- dplyr::select(to_df(.data), ...)
	st_as_stars(set_dim(ret, dim(.data)), dimensions = st_dimensions(.data))
}


#' @name dplyr
select.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "select", ".data", env = environment())
}

#' @param var see \link[dplyr]{pull}
#' @name dplyr
pull.stars = function (.data, var = -1) {
    if (!requireNamespace("dplyr", quietly = TRUE))
        stop("package dplyr required, please install it first") # nocov
    if (!requireNamespace("rlang", quietly = TRUE))
        stop("package rlang required, please install it first") # nocov
	var = rlang::enquo(var)
	structure(dplyr::pull(to_df(.data), !!var), dim = dim(.data))
}

#' @name dplyr
pull.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "pull", ".data", env = environment())
}

#' @name dplyr
#' @param x object of class \code{stars}
#' @export
as.tbl_cube.stars = function(x, ...) {
    if (!requireNamespace("cubelyr", quietly = TRUE))
        stop("package cubelyr required, please install it first") # nocov
	cleanup = function(y) {
		if (is.list(y))
			seq_along(y)
		else
			y
	}
	dims = lapply(expand_dimensions(x), cleanup)
	cubelyr::tbl_cube(dims, c(unclass(x)))
}

#' @name dplyr
#' @param along name or index of dimension to which the slice should be applied
#' @param index integer value(s) for this index
#' @param drop logical; drop dimensions that only have a single index?
#' @examples
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' x1 = read_stars(tif)
#' library(dplyr)
#' x1 %>% slice("band", 2:3)
#' x1 %>% slice("x", 50:100)
slice.stars <- function(.data, along, index, ..., drop = length(index) == 1) {
  #stopifnot(length(index) == 1)
  if (!requireNamespace("rlang", quietly = TRUE))
    stop("package rlang required, please install it first") # nocov
    
  nd <- length(dim(.data))
  indices <- rep(list(rlang::missing_arg()), nd + 1)
  along = rlang::expr_text(rlang::ensym(along))
  ix = which(along == names(st_dimensions(.data)))[1]
  indices[[ix + 1]] <- index
  indices[["drop"]] <- drop
  
  eval(rlang::expr(.data[!!!indices]))
}

#' @name dplyr
slice.stars_proxy = function(.data, ...) {
	collect(.data, match.call(), "slice", ".data", env = environment())
}

#' @name st_coordinates
#' @param .x object to be converted to a tibble
as_tibble.stars = function(.x, ..., add_max = FALSE, center = NA) {
    if (!requireNamespace("dplyr", quietly = TRUE))
        stop("package dplyr required, please install it first") # nocov

	dplyr::as_tibble(append(
			st_coordinates(.x, add_max = add_max, center = center),
			lapply(.x, function(y) structure(y, dim = NULL))
		)
	)
}

#' @name dplyr
#' @param data data set to work on
#' @param replace see \link[tidyr]{replace_na}: list with variable=value pairs, where value is the replacement value for NA's
replace_na.stars = function(data, replace, ...) {
    if (!requireNamespace("tidyr", quietly = TRUE))
        stop("package tidyr required, please install it first") # nocov
    if (!requireNamespace("cubelyr", quietly = TRUE))
        stop("package cubelyr required, please install it first") # nocov
	cb = cubelyr::as.tbl_cube(data)
	d = dim(cb$mets[[1]])
	cb$mets = as.data.frame(lapply(cb$mets, as.vector))
	cb$mets = unclass(tidyr::replace_na(cb$mets, replace, ...))
	for (i in seq_along(cb$mets))
		cb$mets[[i]] = structure(cb$mets[[i]], dim = d)
	st_as_stars(cb$mets, dimensions = get_dims(cb$dims, st_dimensions(data)))
}

#' @name dplyr
replace_na.stars_proxy = function(data, ...) {
	collect(data, match.call(), "replace_na", "data", env = environment())
}


#' ggplot geom for stars objects
#' 
#' ggplot geom for stars objects
#' @name geom_stars
#' @param mapping see \link[ggplot2:geom_tile]{geom_raster}
#' @param data see \link[ggplot2:geom_tile]{geom_raster}
#' @param ... see \link[ggplot2:geom_tile]{geom_raster}
#' @param downsample downsampling rate: e.g. 3 keeps rows and cols 1, 4, 7, 10 etc.; a value of 0 does not downsample; can be specified for each dimension, e.g. \code{c(5,5,0)} to downsample the first two dimensions but not the third.
#' @param sf logical; if \code{TRUE} rasters will be converted to polygons and plotted using \link[ggplot2:ggsf]{geom_sf}.
#' @details \code{geom_stars} returns (a call to) either \link[ggplot2:geom_tile]{geom_raster}, \link[ggplot2]{geom_tile}, or \link[ggplot2:ggsf]{geom_sf}, depending on the raster or vector geometry; for the first to, an \link[ggplot2]{aes} call is constructed with the raster dimension names and the first array as fill variable. Further calls to \link[ggplot2:coord_fixed]{coord_equal} and \link[ggplot2]{facet_wrap} are needed to control aspect ratio and the layers to be plotted; see examples.
#' @export
#' @examples
#' system.file("tif/L7_ETMs.tif", package = "stars") %>% read_stars() -> x
#' library(ggplot2)
#' ggplot() + geom_stars(data = x) +
#'     coord_equal() +
#'     facet_wrap(~band) +
#'     theme_void() +
#'     scale_x_discrete(expand=c(0,0))+
#'     scale_y_discrete(expand=c(0,0))
geom_stars = function(mapping = NULL, data = NULL, ..., downsample = 0, sf = FALSE) {

	if (!requireNamespace("ggplot2", quietly = TRUE))
		stop("package ggplot2 required, please install it first") # nocov

	if (is.null(data)) stop("argument data should not set to a stars or stars_proxy object")

	for (i in seq_along(data)) {
		if (inherits(data[[i]], "units"))
			data[[i]] = units::drop_units(data[[i]])
	}
	if (inherits(data, "stars_proxy"))
		data = st_as_stars(data, downsample = downsample) # fetches data
	else if (any(downsample > 0))
		data = st_downsample(data, downsample)

	if (is_curvilinear(data) || sf)
		data = st_xy2sfc(data, as_points = FALSE)

	d = st_dimensions(data)

	if (has_raster(d) && (is_regular_grid(d) || is_rectilinear(d))) {
		xy = attr(d, "raster")$dimensions
		if (is_regular_grid(d)) {
			if (is.null(mapping))
				mapping = ggplot2::aes(x = !!rlang::sym(xy[1]), y = !!rlang::sym(xy[2]),
					fill = !!rlang::sym(names(data)[1]))
			ggplot2::geom_raster(mapping = mapping, data = dplyr::as_tibble(data), ...)
		} else {  # rectilinear: use geom_rect, passing on cell boundaries
			xy_max = paste0(xy, "_max")
			if (is.null(mapping))
				mapping = ggplot2::aes(xmin = !!rlang::sym(xy[1]), ymin = !!rlang::sym(xy[2]),
					xmax = !!rlang::sym(xy_max[1]), ymax = !!rlang::sym(xy_max[2]),
					fill = !!rlang::sym(names(data)[1]))
			ggplot2::geom_rect(mapping = mapping, data = dplyr::as_tibble(data, add_max = TRUE), ...)
		}
	} else if (has_sfc(d)) {
		if (is.null(mapping))
			mapping = ggplot2::aes(fill = !!rlang::sym(names(data)[1]))
		ggplot2::geom_sf(data = st_as_sf(data, long = TRUE), color = NA, mapping = mapping, ...)
	} else
		stop("geom_stars only works for objects with raster or vector geometries")
}

#' @name geom_stars
theme_stars = function(...) {

	if (!requireNamespace("ggplot2", quietly = TRUE))
		stop("package ggplot2 required, please install it first") # nocov

	# coord_equal() +
    # scale_fill_viridis() +
    # scale_x_discrete(expand=c(0,0)) +
    # scale_y_discrete(expand=c(0,0)) +
    ggplot2::theme_void()
}

register_all_s3_methods = function() {
	register_s3_method("cubelyr", "as.tbl_cube", "stars") # nocov start
	register_s3_method("dplyr", "filter", "stars") 
	register_s3_method("dplyr", "filter", "stars_proxy") 
	register_s3_method("dplyr", "as_tibble", "stars")
	register_s3_method("dplyr", "select", "stars")
	register_s3_method("dplyr", "select", "stars_proxy")
	register_s3_method("dplyr", "mutate", "stars")
	register_s3_method("dplyr", "mutate", "stars_proxy")
	register_s3_method("dplyr", "pull", "stars")
	register_s3_method("dplyr", "pull", "stars_proxy")
	register_s3_method("dplyr", "slice", "stars")
	register_s3_method("dplyr", "slice", "stars_proxy")
	register_s3_method("dplyr", "transmute", "stars")
	register_s3_method("dplyr", "transmute", "stars_proxy")
	register_s3_method("tidyr", "replace_na", "stars")
	register_s3_method("tidyr", "replace_na", "stars_proxy")
	register_s3_method("lwgeom", "st_transform_proj", "stars")
	register_s3_method("sf", "st_join", "stars")
	register_s3_method("spatstat.geom", "as.owin", "stars")
	register_s3_method("xts", "as.xts", "stars") # nocov end
}

# from: https://github.com/tidyverse/hms/blob/master/R/zzz.R
# Thu Apr 19 10:53:24 CEST 2018
#nocov start
register_s3_method <- function(pkg, generic, class, fun = NULL) {
  stopifnot(is.character(pkg), length(pkg) == 1)
  stopifnot(is.character(generic), length(generic) == 1)
  stopifnot(is.character(class), length(class) == 1)

  if (is.null(fun)) {
    fun <- get(paste0(generic, ".", class), envir = parent.frame())
  } else {
    stopifnot(is.function(fun))
  }

  if (pkg %in% loadedNamespaces()) {
    registerS3method(generic, class, fun, envir = asNamespace(pkg))
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(
    packageEvent(pkg, "onLoad"),
    function(...) {
      registerS3method(generic, class, fun, envir = asNamespace(pkg))
    }
  )
}
#nocov end
