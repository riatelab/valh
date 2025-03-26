#' @name vl_isochrone
#' @title Get Isochrones from a Point
#' @description
#' Build and send a Valhalla API query to get isochrones from a point.
#' Note that you must provide either 'times' or 'distances' to compute the isochrones
#' at given times or distances from the center point.
#' @param center one point from which to compute isochrones.
#' \code{center} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param times a vector of travel times (in minutes) to compute the
#' isochrones.
#' @param distances a vector of travel distances (in meters) to compute the
#' isochrones.
#' @param costing the costing model to use for the route. Default is
#' "auto".\cr
#' @param costing_options a list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' @param val.server the URL of the Valhalla server. Default is the demo server
#' (https://valhalla1.openstreetmap.de/).
#' @returns An sf MULTIPOLYGON object is returned with the following fields:
#' 'metric' (the metric used, either 'time' or 'distance)
#' and 'contour' (the value of the metric).
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#'
#' # Extract the first point and compute isochrones at 3, 6, 9 and 12 kilometers,
#' # using the "auto" costing model
#' pt1 <- apotheke.df[1, c("lon", "lat")]
#' iso1 <- vl_isochrone(center = pt1, distances = c(3, 6, 9, 12), costing = "auto")
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'                        quiet = TRUE)
#' # Extract the first point and compute isochrones at 15, 30, 45 and 60 minutes
#' # using the "bicycle" costing model
#' pt2 <- apotheke.sf[1, ]
#' iso2 <- vl_isochrone(center = pt2, times = c(15, 30, 45, 60), costing = "bicycle")
#' }
#' @export
vl_isochrone <- function(
  center,
  times,
  distances,
  costing = "auto",
  costing_options = list(),
  val.server="https://valhalla1.openstreetmap.de/"
) {
  # Handle input point(s)
  loc <- input_route(x = center, single = TRUE, id = "center")
  oprj <- loc$oprj
  locs <- lapply(1:length(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Handle the times and distances arguments
  if (!missing(times) && !missing(distances)) {
    stop("You must provide either 'times' or 'distances', not both")
  } else if (!missing(times)) {
    contours <- lapply(times, function(x) list(time = x))
  } else if (!missing(distances)) {
    contours <- lapply(distances, function(x) list(distance = x))
  } else {
    stop("You must provide either 'times' or 'distances'")
  }

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    polygons = TRUE,
    contours = contours,
    locations = locs
  )
  if (is.list(costing_options) & length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(base_url(val.server), 'isochrone?json=', jsonlite::toJSON(json, auto_unbox = TRUE))

  # Send the request and handle possible errors
  e <- try(
  {
    req_handle <- curl::new_handle(verbose = FALSE)
    curl::handle_setopt(req_handle, useragent = "valh_R_package")
    r <- curl::curl_fetch_memory(utils::URLencode(url), handle = req_handle)
  },
    silent = TRUE
  )
  if (inherits(e, "try-error")) {
    stop(e, call. = FALSE)
  }
  test_http_error(r)

  gdf <- sf::st_read(dsn = rawToChar(r$content), quiet = TRUE)

  if (!is.na(oprj)) {
    gdf <- sf::st_transform(gdf, oprj)
  }

  return(sf::st_cast(gdf[, c('contour', 'metric')], 'MULTIPOLYGON'))
}