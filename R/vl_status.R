#' @title Get Valhalla Service Status
#' @description
#' Use this function to return information on the Valhalla server (version etc.).\cr
#' This function interfaces with the \emph{Status} Valhalla service.
#' @param server URL of the Valhalla server.
#' @param verbose if TRUE and if the service has it enabled,
#' it will return additional information about the loaded tileset.
#'
#' @returns A list with information on the Valhalla service is returned.
#' @export
#'
#' @examples
#' vl_status("https://valhalla1.openstreetmap.de/", verbose = FALSE)
vl_status <- function(server = getOption("valh.server"),
                      verbose = FALSE) {
  # Build the JSON argument of the request
  vrbs <- ifelse(isTRUE(verbose), '?json={"verbose": true}', "")

  # Construct the url
  url <- paste0(base_url(server), "status", vrbs)

  # Send the request and handle possible errors
  r <- get_results(url)

  # Parse the response to a spatial data frame
  res <- jsonlite::fromJSON(rawToChar(r$content))

  # Convert to human readable date format
  res$tileset_last_modified <- as.POSIXct(res$tileset_last_modified, "%Y-%m-%d %H:%M")
  if (!is.null(res$osm_changeset)) {
    res$osm_changeset <- as.POSIXct(res$osm_changeset)
  }

  if (!is.null(res$bbox)) {
    res$bbox <- sf::st_read(
      jsonlite::toJSON(res$bbox, auto_unbox = TRUE),
      quiet = TRUE
    )
  }

  return(res)
}
