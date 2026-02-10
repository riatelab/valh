#' @name vl_elevation
#' @title Get elevation along a route
#' @description
#' Build and send a Valhalla API query to get the elevation at a
#' set of input locations.\cr
#' This function interfaces with the \emph{height} service.\cr
#' If \code{sampling_dist} is provided, the elevation is sampled at regular
#' intervals along the input locations.
#' @param loc one (or multiples) point(s) at which to get elevation.
#' \code{loc} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param sampling_dist distance between each point to sample the elevation
#' (in meters). Default is no sampling.
#' @param server URL of the Valhalla server.
#' @returns An sf POINT object is returned with the following fields: 'distance'
#' (the distance from the first points), 'height' (the sampled height on the DEM)
#' and 'geometry' (the geometry of the sampled point).
#'
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#' # The first 5 points
#' pts <- apotheke.df[1:5, c("lon", "lat")]
#' # Ask for the elevation at these points
#' elev1 <- vl_elevation(loc = pts)
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' # The first 5 points
#' pts2 <- apotheke.sf[1:5, ]
#' # Ask for the elevation at these points
#' elev2 <- vl_elevation(loc = pts2)
#' # Ask for elevation between the first and the second points,
#' # sampling every 100 meters
#' elev3 <- vl_elevation(loc = apotheke.sf[1:2, ], sampling_dist = 100)
#' # Plot the corresponding elevation profile
#' plot(as.matrix(st_drop_geometry(elev3)), type = "l")
#'
#' # Input is a route (sf LINESTRING) from vl_route
#' # Compute the route between the first and the second points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' src <- apotheke.sf[1, ]
#' dst <- apotheke.sf[2, ]
#' route <- vl_route(src = src, dst = dst)
#'
#' # Split the LINESTRING into its composing points
#' pts_route <- sf::st_cast(route, "POINT")
#' # Ask for the elevation at these points
#' elev4 <- vl_elevation(loc = pts_route)
#'
#' # Plot the elevation profile
#' plot(as.matrix(st_drop_geometry(elev4)), type = "l")
#' }
#' @export
vl_elevation <- function(loc, sampling_dist,
                         server = getOption("valh.server")) {
  # Handle input point(s)
  loc <- input_locate(x = loc)
  oprj <- loc$oprj
  locs <- lapply(seq_along(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Build the JSON argument of the request
  json <- list(
    range = TRUE,
    shape = locs
  )

  # Add sampling distance if provided
  if (!missing(sampling_dist)) {
    json$resample_distance <- sampling_dist
  }

  # Construct the URL
  url <- paste0(base_url(server), "height")
  json_body <- jsonlite::toJSON(json, auto_unbox = TRUE)

  # Send the POST request and handle possible errors
  r <- get_results(url, json_body)

  # Parse the response
  res <- jsonlite::fromJSON(rawToChar(r$content))

  gdf <- sf::st_sf(
    distance = res$range_height[, 1],
    height = res$range_height[, 2],
    geometry = sf::st_as_sfc(paste0("POINT(", res$shape$lon, " ", res$shape$lat, ")")),
    crs = 4326
  )
  if (!is.na(oprj)) {
    gdf <- sf::st_transform(gdf, oprj)
  }
  return(gdf)
}
