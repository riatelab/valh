#' @name vl_route
#' @title Get the Shortest Path Between Two Points
#' @description Build and send a Valhalla API query to get the travel geometry
#' between two points.\cr
#' This function interfaces with the \emph{route} Valhalla service.\cr
#' Use \code{src} and \code{dst} to get the shortest direct route between
#' two points. Use \code{loc} to get the shortest route between two points using
#' ordered waypoints.
#'
#' @param src starting point of the route.
#' \code{src} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' If relevant, row names are used as identifiers.\cr
#' If \code{src} is a data.frame, a matrix, an sfc object or an sf object then
#' only the first row or element is considered.
#' @param dst destination of the route.
#' \code{dst} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' If relevant, row names are used as identifiers.\cr
#' If \code{dst} is a data.frame, a matrix, an sfc object or an sf object then
#' only the first row or element is considered.
#'
#' @param loc starting point, waypoints (optional) and destination of the
#' route. \code{loc} can be: \itemize{
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' The first row or element is the starting point then waypoints are used in
#' the order they are stored in \code{loc} and the last row or element is
#' the destination.\cr
#' If relevant, row names are used as identifiers.
#' @param costing costing model to use.
#' @param costing_options list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' @param server URL of the Valhalla server.
#' @return
#' The output of this function is an sf LINESTRING of the shortest route.\cr
#' It contains 4 fields: \itemize{
#'   \item starting point identifier
#'   \item destination identifier
#'   \item travel time in minutes
#'   \item travel distance in kilometers.
#'   }
#'
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#' src <- apotheke.df[1, c("lon", "lat")]
#' dst <- apotheke.df[2, c("lon", "lat")]
#' # Route between the two points, using bicycle costing model
#' route1 <- vl_route(src = src, dst = dst, costing = "bicycle")
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' srcsf <- apotheke.sf[1, ]
#' dstsf <- apotheke.sf[2, ]
#' # Route between the two points, using bicycle costing model and a custom
#' # costing option
#' route2 <- vl_route(
#'   src = srcsf,
#'   dst = dstsf,
#'   costing = "bicycle",
#'   costing_options = list(cycling_speed = 19)
#' )
#' }
#' @export
vl_route <- function(src, dst, loc,
                     costing = "auto", costing_options = list(),
                     server = getOption("valh.server")) {
  # Handle input points
  if (missing(loc)) {
    # From src to dst
    src <- input_route(x = src, id = "src", single = TRUE)
    dst <- input_route(x = dst, id = "dst", single = TRUE)
    id1 <- src$id
    id2 <- dst$id
    oprj <- src$oprj
    locs <- list(
      list(lon = src$lon, lat = src$lat),
      list(lon = dst$lon, lat = dst$lat)
    )
  } else {
    # from src to dst via x, y, z... (data.frame or sf input)
    loc <- input_route(x = loc, single = FALSE)
    oprj <- loc$oprj
    id1 <- loc$id1
    id2 <- loc$id2
    locs <- lapply(seq_along(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))
  }

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    locations = locs
  )
  if (is.list(costing_options) && length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(
    base_url(server),
    "route?json=",
    jsonlite::toJSON(json, auto_unbox = TRUE)
  )

  # Send the request and handle possible errors
  r <- get_results(url)

  # Parse the response to a spatial data frame
  res <- jsonlite::fromJSON(rawToChar(r$content))
  gdf <- do.call(rbind, lapply(res$trip$legs$shape, function(x) googlePolylines::decode(x)[[1]] / 10))

  rosf <- sf::st_sf(
    src = id1,
    dst = id2,
    duration = res$trip$summary$time / 60,
    distance = res$trip$summary$length,
    geometry = sf::st_as_sfc(paste0("LINESTRING(", paste0(gdf$lon, " ", gdf$lat, collapse = ", "), ")")),
    crs = 4326,
    row.names = paste(id1, id2, sep = "_")
  )

  # Use input CRS if any
  if (!is.na(oprj)) {
    rosf <- sf::st_transform(rosf, oprj)
  }
  return(rosf)
}
