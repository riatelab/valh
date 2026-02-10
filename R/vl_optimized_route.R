#' @name vl_optimized_route
#' @title Get the Optimized Route Between Multiple Points
#' @description
#' Build and send a Valhalla API query to get the optimized route
#' (and so a solution to the Traveling Salesman Problem) between multiple points.\cr
#' This function interfaces with the \emph{optimized_route} Valhalla service.
#' @param loc starting point and waypoints to reach along the
#' route. \code{loc} can be: \itemize{
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' The first row or element is the starting point.\cr
#' Row names, if relevant, or element indexes are used as identifiers.
#' @param end_at_start logical indicating whether the route should end at the
#' first point (making the trip a loop).
#' @param costing costing model to use.
#' @param costing_options list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' @param server URL of the Valhalla server.
#' @return a list of two elements: \itemize{
#'   \item summary: a list whose elements are a summary of the trip (duration,
#'   distance, presence of tolls, highways, time restrictions and ferries),
#'   \item shape: an sf LINESTRING of the optimized route.
#' }
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#' pts1 <- apotheke.df[1:6, c("lon", "lat")]
#'
#' # Compute the optimized route between the first 6 points
#' # (starting point, 4 waypoints and final destination), by bike
#' trip1a <- vl_optimized_route(loc = pts1, end_at_start = FALSE, costing = "bicycle")
#'
#' # Compute the optimized route between the first 6 points returning to the
#' # starting point, by bike
#' trip1b <- vl_optimized_route(loc = pts1, end_at_start = TRUE, costing = "bicycle")
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#' pts2 <- apotheke.sf[1:6, ]
#' # Compute the optimized route between the first 6 points
#' # (starting point, 4 waypoints and final destination)
#' trip2a <- vl_optimized_route(loc = pts2, end_at_start = FALSE, costing = "auto")
#'
#' # Compute the optimized route between the first 6 points, returning to the
#' # starting point
#' trip2b <- vl_optimized_route(loc = pts2, end_at_start = TRUE, costing = "auto")
#' }
#' @export
vl_optimized_route <- function(loc, end_at_start = FALSE,
                               costing = "auto", costing_options = list(),
                               server = getOption("valh.server")) {
  # Handle input points
  if (end_at_start) {
    loc <- rbind(loc, loc[1, ])
  }
  loc <- input_route(x = loc, id = "loc", single = FALSE, all.ids = TRUE)
  oprj <- loc$oprj
  n_pts <- length(loc$lon)
  n_pts_input <- ifelse(end_at_start, n_pts - 1, n_pts)
  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    locations = lapply(1:n_pts, function(i) list(lon = loc$lon[i], lat = loc$lat[i]))
  )
  if (is.list(costing_options) && length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(base_url(server), "optimized_route")
  json_body <- jsonlite::toJSON(json, auto_unbox = TRUE)

  # Send the POST request and handle possible errors
  r <- get_results(url, json_body)

  # Parse the response
  res <- jsonlite::fromJSON(rawToChar(r$content))

  # Prepare the result
  result <- list()
  result$summary <- list(
    duration = res$trip$summary$time / 60,
    distance = res$trip$summary$length,
    has_toll = res$trip$summary$has_toll,
    has_highway = res$trip$summary$has_highway,
    has_time_restrictions = res$trip$summary$has_time_restrictions,
    has_ferry = res$trip$summary$has_ferry
  )

  t <- do.call(rbind, lapply(
    seq_along(res$trip$legs$shape),
    function(ix) {
      coords <- googlePolylines::decode(res$trip$legs$shape[ix])[[1]] / 10
      s <- res$trip$locations[ix, ]$original_index + 1
      e <- res$trip$locations[ix + 1, ]$original_index + 1
      # Handle the case where the route ends at the first point
      if (end_at_start && e > n_pts_input) {
        e <- 1
      }
      return(
        list(
          geometry = paste0("LINESTRING(", paste0(coords$lon, " ", coords$lat, collapse = ", "), ")"),
          start = s,
          end = e
        )
      )
    }
  ))

  result$shape <- sf::st_sf(
    start = unlist(t[, "start"]),
    end = unlist(t[, "end"]),
    geometry = sf::st_as_sfc(t[, "geometry"]),
    crs = 4326,
    row.names = paste(t[, "start"], t[, "end"], sep = "_")
  )

  if (!is.na(oprj)) {
    result$shape <- sf::st_transform(result$shape, oprj)
  }

  return(result)
}
