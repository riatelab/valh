.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Data: (c) OpenStreetMap contributors, ODbL 1.0 - http://www.openstreetmap.org/copyright")
  packageStartupMessage("Routing: Valhalla - valhalla.github.io/valhalla")
}

.onLoad <- function(libname, pkgname) {
  if (is.null(getOption("valh.server"))){
    options(valh.server = "https://valhalla1.openstreetmap.de/")
  }
}
