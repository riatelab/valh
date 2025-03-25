#' @name vl_elevation
#' @title Get Elevation Along a Route
#' @description Build and send a Valhalla API query to get the elevation at a
#' set of input locations.
#' This function interfaces with the \emph{height} service.\cr
#' If \code{sampling_dist} is provided, the elevation is sampled at regular
#' intervals along the input locations.
#' @param loc one (or multiples) point(s) to snap to the street network.
#' \code{loc} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param sampling_dist the distance between each point to sample the elevation
#' (in meters). Default is 'NA' (no sampling).
#' @param val.server the URL of the Valhalla server. Default is the demo server
#' (https://valhalla1.openstreetmap.de/).
#' @returns An sf POINT object is returned with the following fields: 'distance'
#' (the distance from the first points), 'height' (the sampled height on the DEM)
#' and 'geometry' (the geometry of the sampled point).
#' @export
vl_elevation <- function(loc, sampling_dist = NA, val.server = 'https://valhalla1.openstreetmap.de/') {
  # Handle input point(s)
  loc <- input_locate(x = loc, id = "loc")
  oprj <- loc$oprj
  locs <- lapply(1:length(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Build the JSON argument of the request
  json <- list(
    range = TRUE,
    shape = locs
  )

  # Add sampling distance if provided
  if (!is.na(sampling_dist)) {
    json$resample_distance <- sampling_dist
  }

  # Construct the URL
  url <- paste0(base_url(val.server), 'height?json=', jsonlite::toJSON(json, auto_unbox = TRUE))

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

  # Parse the response
  res <- jsonlite::fromJSON(rawToChar(r$content))

  gdf <- sf::st_sf(
    distance = res$range_height[,1],
    height = res$range_height[,2],
    geometry = sf::st_as_sfc(paste0("POINT(", res$shape$lon, " ", res$shape$lat, ")")),
    crs = 4326
  )
  if (!is.na(oprj)) {
    gdf <- sf::st_transform(gdf, oprj)
  }
  return(gdf)
}