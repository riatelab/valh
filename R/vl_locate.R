#' @name vl_locate
#' @title Get the Nearest Point on the Road Network
#' @description This function interfaces with the \emph{nearest} Valhalla
#' service.\cr
#' @param loc one (or multiples) point(s) to snap to the street network.
#' \code{loc} can be: \itemize{
#'   \item a vector of coordinates (longitude and latitude, WGS 84),
#'   \item a data.frame of longitudes and latitudes (WGS 84),
#'   \item a matrix of longitudes and latitudes (WGS 84),
#'   \item an sfc object of type POINT,
#'   \item an sf object of type POINT.
#' }
#' @param verbose a logical indicating whether to return additional information
#' @param costing the costing model to use for the route. Default is
#' "auto".\cr
#' @param costing_options a list of options to use with the costing model
#' (see \url{https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-options}
#' for more details about the options available for each costing model).
#' Default is an empty list.\cr
#' @param val.server the URL of the Valhalla server. Default is the demo server
#' (https://valhalla1.openstreetmap.de/).
#' @returns If there is only one input point, return a single sf object
#' containing the nearest point(s) on the road network.
#' If there is more than one input point, return a list of sf objects,
#' one for each input point.
#' @export
vl_locate <- function(loc, verbose = F, costing="auto", costing_options=list(), val.server='https://valhalla1.openstreetmap.de/') {
  # Handle input point(s)
  loc <- input_locate(x = loc, id = "loc")
  oprj <- loc$oprj
  locs <- lapply(1:length(loc$lon), function(i) list(lon = loc$lon[i], lat = loc$lat[i]))

  # Build the JSON argument of the request
  json <- list(
    costing = costing,
    verbose = verbose,
    locations = locs
  )
  if (is.list(costing_options) & length(costing_options) >= 0) {
    json$costing_options <- list()
    json$costing_options[[costing]] <- costing_options
  }

  # Construct the URL
  url <- paste0(base_url(val.server), 'locate?json=', jsonlite::toJSON(json, auto_unbox = TRUE))

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

  # Parse the response to a spatial data frame
  res <- jsonlite::fromJSON(rawToChar(r$content))

  if (length(locs) == 1) {
    # If there is only one input point, return a single sf object
    gdf <- sf::st_as_sf(
      as.data.frame(res$edges),
      coords = c("correlated_lat", "correlated_lon"),
      crs = 4326
    )
    if (!is.na(oprj)) {
      gdf <- sf::st_transform(gdf, oprj)
    }
    return(gdf)
  } else {
    # If there is more than one input point, return a list of sf objects,
    # one for each input point
    li <- lapply(1:length(res$edges), function(i) {
      t <- sf::st_as_sf(
        as.data.frame(res$edges[[i]]),
        coords = c("correlated_lat", "correlated_lon"),
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
