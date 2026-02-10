#' @name vl_matrix
#' @title Get Travel Time Matrices Between Points
#' @description
#' Build and send Valhalla API queries to get travel time matrices
#' between points.\cr
#' This function interfaces the \emph{matrix} Valhalla service.\cr
#' Use \code{src} and \code{dst} to set different origins and destinations.
#' Use \code{loc} to compute travel times or travel distances between all
#' points.
#' @param src origin points.
#' \code{src} can be: \itemize{
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' If relevant, row names are used as identifiers.
#' @param dst destination.
#' \code{dst} can be: \itemize{
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' If relevant, row names are used as identifiers.
#' @param loc points. \code{loc} can be: \itemize{
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' If relevant, row names are used as identifiers.
#' @param costing costing model to use.
#' @param costing_options list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' @param server URL of the Valhalla server.
#' @return
#' The output of this function is a list composed of one or two matrices
#' and 2 data.frames
#' \itemize{
#'   \item{durations}: a matrix of travel times (in minutes)
#'   \item{distances}: a matrix of distances (in specified units, default to
#'   kilometers)
#'   \item{sources}: a data.frame of the coordinates of the points actually
#'   used as starting points (EPSG:4326 - WGS84)
#'   \item{destinations}: a data.frame of the coordinates of the points actually
#'   used as destinations (EPSG:4326 - WGS84)
#'   }
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#' # Travel time matrix
#' distA <- vl_matrix(loc = apotheke.df[1:50, c("lon", "lat")])
#' # First 5 rows and columns
#' distA$durations[1:5, 1:5]
#'
#' # Travel time matrix with different sets of origins and destinations
#' distA2 <- vl_matrix(
#'   src = apotheke.df[1:10, c("lon", "lat")],
#'   dst = apotheke.df[11:20, c("lon", "lat")]
#' )
#' # First 5 rows and columns
#' distA2$durations[1:5, 1:5]
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' distA3 <- vl_matrix(loc = apotheke.sf[1:10, ])
#' # First 5 rows and columns
#' distA3$durations[1:5, 1:5]
#'
#' # Travel time matrix with different sets of origins and destinations
#' distA4 <- vl_matrix(src = apotheke.sf[1:10, ], dst = apotheke.sf[11:20, ])
#' # First 5 rows and columns
#' distA4$durations[1:5, 1:5]
#' }
#' @export
vl_matrix <- function(src, dst, loc,
                      costing = "auto", costing_options = list(),
                      server = getOption("valh.server")) {
  # Handle input points
  if (!missing(loc)) {
    dst_r <- src_r <- input_table(x = loc, id = "loc")
  } else {
    src_r <- input_table(x = src, id = "src")
    dst_r <- input_table(x = dst, id = "dst")
  }
  sources <- lapply(seq_along(src_r$lon), function(i) list(lon = src_r$lon[i], lat = src_r$lat[i]))
  targets <- lapply(seq_along(dst_r$lon), function(i) list(lon = dst_r$lon[i], lat = dst_r$lat[i]))

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    sources = sources,
    targets = targets,
    verbose = TRUE
  )
  if (is.list(costing_options) && length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(base_url(server), "sources_to_targets")
  json_body <- jsonlite::toJSON(json, auto_unbox = TRUE)

  # Send the POST request and handle possible errors
  r <- get_results(url, json_body)

  # Parse the response
  res <- jsonlite::fromJSON(rawToChar(r$content))

  # Extract matrices
  zdi <- lapply(res$sources_to_targets, function(x) x$distance)
  zdu <- lapply(res$sources_to_targets, function(x) x$time)
  ncol <- nrow(dst_r)
  mat_durations <- matrix(unlist(zdu, use.names = FALSE), ncol = ncol, byrow = TRUE)
  mat_distances <- matrix(unlist(zdi, use.names = FALSE), ncol = ncol, byrow = TRUE)
  mat_durations <- round(mat_durations / 60, 1)
  dimnames(mat_durations) <- dimnames(mat_distances) <- list(src_r$id, dst_r$id)

  # Extract actual sources and destinations
  sources <- res$sources
  destinations <- res$targets

  return(list(
    durations = mat_durations,
    distances = mat_distances,
    sources = sources,
    destinations = destinations
  ))
}
