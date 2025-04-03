#' @name vl_isochrone
#' @title Get isochrones and isodistances from a point
#' @description
#' Build and send a Valhalla API query to get isochrones or
#' isodistances from a point.\cr
#' This function interfaces with the \emph{Isochrone & Isodistance} service.\cr
#' Note that you must provide either 'times' or 'distances' to compute the isochrones
#' at given times or distances from the center point.
#' @param loc one point from which to compute isochrones.
#' \code{loc} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param times vector of travel times (in minutes) to compute the
#' isochrones. The maximum number of isochrones is 4. The minimal value must
#' be greater than 0.
#' @param distances vector of travel distances (in kilometers) to compute the
#' isochrones. The maximum number of isochrones is 4. The minimal value must
#' be greater than 0.
#' @param costing costing model to use.
#' @param costing_options list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' @param server URL of the Valhalla server.
#' @returns An sf MULTIPOLYGON object is returned with the following fields:
#' 'metric' (the metric used, either 'time' or 'distance')
#' and 'contour' (the value of the metric).
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#'
#' # Extract the first point and compute isochrones at 3, 6, 9 and 12 kilometers,
#' # using the "auto" costing model
#' pt1 <- apotheke.df[1, c("lon", "lat")]
#' iso1 <- vl_isochrone(loc = pt1, distances = c(3, 6, 9, 12), costing = "auto")
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' # Extract the first point and compute isochrones at 15, 30, 45 and 60 minutes
#' # using the "bicycle" costing model
#' pt2 <- apotheke.sf[1, ]
#' iso2 <- vl_isochrone(loc = pt2, times = c(15, 30, 45, 60), costing = "bicycle")
#' }
#' @export
vl_isochrone <- function(loc, times, distances,
                         costing = "auto", costing_options = list(),
                         server = getOption("valh.server")) {
  # Handle input point(s)
  loc <- input_route(x = loc, single = TRUE, id = "loc")
  oprj <- loc$oprj
  locs <- lapply(seq_along(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Handle the times and distances arguments
  if (!missing(times) && !missing(distances)) {
    stop("You must provide either 'times' or 'distances', not both.", call. = FALSE)
  } else if (!missing(times)) {
    if (isFALSE(min(times) > 0)) {
      stop("The minimal value of 'times' must be greater than 0.", call. = FALSE)
    }
    if (isFALSE(length(times) < 5)) {
      stop(paste0(
        "The Valhalla isochrone service can only produce a maximum",
        "of 4 isochrones at a time."
      ), call. = FALSE)
    }
    contours <- lapply(times, function(x) list(time = x))
  } else if (!missing(distances)) {
    if (isFALSE(min(distances) > 0)) {
      stop("The minimal value of 'distances' must be greater than 0.", call. = FALSE)
    }
    if (isFALSE(length(distances) < 5)) {
      stop(paste0(
        "The Valhalla isochrone service can only produce a maximum",
        "of 4 isochrones at a time."
      ), call. = FALSE)
    }
    contours <- lapply(distances, function(x) list(distance = x))
  } else {
    stop("You must provide either 'times' or 'distances'.", call. = FALSE)
  }

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    polygons = TRUE,
    contours = contours,
    locations = locs
  )
  if (is.list(costing_options) && length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(
    base_url(server),
    "isochrone?json=",
    jsonlite::toJSON(json, auto_unbox = TRUE)
  )

  # Send the request and handle possible errors
  r <- get_results(url)

  gdf <- sf::st_read(dsn = rawToChar(r$content), quiet = TRUE)

  if (!is.na(oprj)) {
    gdf <- sf::st_transform(gdf, oprj)
  }

  return(sf::st_cast(gdf[, c("contour", "metric")], "MULTIPOLYGON"))
}
