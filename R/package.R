#' @title Shortest Paths and Travel Time with the OpenStreetMap-Based Routing Service Valhalla
#' @name valh
#' @description An interface between R and the Valhalla API.\cr
#' Valhalla is a routing
#' service based on OpenStreetMap data.
#' See \url{https://valhalla.github.io/valhalla/} for more
#' information.\cr
#' This package enables the computation of routes, trips, isochrones and
#' travel distances matrices.\cr
#' \itemize{
#' \item{\code{\link{vl_matrix}}: Build and send Valhalla API queries to get travel
#' time matrices between points. This function interfaces the \emph{matrix}
#' Valhalla service.}
#' \item{\code{\link{vl_route}}: Build and send a Valhalla API query to get the
#' travel geometry between two points. This function interfaces with the
#' \emph{route} Valhalla service.}
#' \item{\code{\link{vl_optimized_route}}: Build and send a Valhalla API query to get the
#' shortest travel geometry between multiple unordered points. This function
#' interfaces the \emph{optimized_route} Valhalla service. Use this function to resolve the
#' travelling salesman problem.}
#' \item{\code{\link{vl_locate}}: Build and send an Valhalla API query to get the
#' nearest point on the street network. This function interfaces the
#' \emph{locate} Valhalla service.}
#' \item{\code{\link{vl_isochrone}}: This function computes areas that are
#' reachable within a given time span (or road distance) from a point and returns the reachable
#' regions as polygons. These areas of equal travel time are called isochrones.
#' This function interfaces the \emph{isochrone & isodistance} Valhalla service.}
#' \item{\code{\link{vl_elevation}}: Build and send a Valhalla API query to get
#' the elevation at a set of input locations. This function interfaces with the
#' \emph{height} Valhalla service.}
#' \item{\code{\link{vl_status}}: Build and send a Valhalla API query to get
#' information on the Valhalla server (version etc.).. This function interfaces with the
#' \emph{status} Valhalla service.}
#' }
#' @md
#' @note
#' This package relies on the usage of a running Valhalla service
#' (tested with versions 3.4.x & 3.5.x of Valhalla).\cr
#'
#' To use a custom Valhalla instance, you just need to change the
#' `valh.server` option to the url of the instance :\cr
#' `options(valh.server = "http://address.of.the.server/")`\cr
#' You can also set this option in your `.Rprofile` file to make it permanent.
#'
#' The package ships a sample dataset of 100 random pharmacies in Berlin
#' (© OpenStreetMap contributors - \url{https://www.openstreetmap.org/copyright/en}).\cr
#' The sf dataset uses the projection WGS 84 / UTM zone 34N (EPSG:32634).\cr
#' The csv dataset uses WGS 84 (EPSG:4326).\cr
"_PACKAGE"
