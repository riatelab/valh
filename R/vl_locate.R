#' @name vl_locate
#' @title Get the nearest point on the road network
#' @description
#' This function interfaces with the \emph{locate} Valhalla service.
#' @param loc one (or multiples) point(s) to snap to the street network.
#' \code{loc} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param verbose logical indicating whether to return additional information.
#' @param costing costing model to use.
#' @param costing_options list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' @param server URL of the Valhalla server.
#' @returns If there is only one input point, return a single sf object
#' containing the nearest point(s) on the road network.
#' If there is more than one input point, return a list of sf objects,
#' one for each input point.
#' @examples
#' \dontrun{
#' # Inputs are data frames
#' apotheke.df <- read.csv(system.file("csv/apotheke.csv", package = "valh"))
#'
#' loc <- apotheke.df[1, c("lon", "lat")]
#'
#' # Ask for the nearest point on the road network at this point
#' # using "auto" costing model
#' on_road_1 <- vl_locate(loc = loc)
#'
#' # Inputs are sf points
#' library(sf)
#' apotheke.sf <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"),
#'   quiet = TRUE
#' )
#'
#' # Ask for one point
#' locsf1 <- apotheke.sf[1, ]
#' # The result is a single sf object
#' on_road_2 <- vl_locate(loc = locsf1)
#'
#' # Ask for multiple points
#' locsf2 <- apotheke.sf[1:3, ]
#' # The result is a list of sf objects
#' on_road_3 <- vl_locate(loc = locsf2)
#' }
#' @export
vl_locate <- function(loc, verbose = FALSE,
                      costing = "auto", costing_options = list(),
                      server = getOption("valh.server")) {
  # Handle input point(s)
  loc <- input_locate(x = loc)
  oprj <- loc$oprj
  locs <- lapply(seq_along(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    verbose = verbose,
    locations = locs
  )
  if (is.list(costing_options) && length(costing_options) > 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(base_url(server), "locate")
  json_body <- jsonlite::toJSON(json, auto_unbox = TRUE)

  # Send the POST request and handle possible errors
  r <- get_results(url, json_body)

  # Parse the response to a spatial data frame
  res <- jsonlite::fromJSON(rawToChar(r$content))

  if (length(locs) == 1) {
    # If there is only one input point, return a single sf object
    gdf <- sf::st_as_sf(
      as.data.frame(res$edges),
      coords = c("correlated_lon", "correlated_lat"),
      crs = 4326
    )
    if (!is.na(oprj)) {
      gdf <- sf::st_transform(gdf, oprj)
    }
    return(gdf)
  } else {
    # If there is more than one input point, return a list of sf objects,
    # one for each input point
    li <- lapply(seq_along(res$edges), function(i) {
      t <- sf::st_as_sf(
        as.data.frame(res$edges[[i]]),
        coords = c("correlated_lon", "correlated_lat"),
        crs = 4326
      )
      if (!is.na(oprj)) {
        t <- sf::st_transform(t, oprj)
      }
      return(t)
    })
    return(li)
  }
}
