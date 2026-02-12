
# valh <img src="man/figures/logo.png" align="right" width="140"/>

[![CRAN](https://www.r-pkg.org/badges/version/valh)](https://CRAN.R-project.org/package=valh)
[![R build
status](https://github.com/riatelab/valh/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/riatelab/valh/actions)
[![codecov](https://codecov.io/gh/riatelab/valh/graph/badge.svg)](https://app.codecov.io/gh/riatelab/valh)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

[Valhalla](https://valhalla.github.io/valhalla/) is a routing service
that is based on OpenStreetMap data. This package provides an interface
to the Valhalla API from R. It allows you to query the Valhalla API for
routes, isochrones, time-distance matrices, nearest point on the road
network, and elevation data.

This package relies on the usage of a [running Valhalla
server](https://github.com/riatelab/valh?tab=readme-ov-file#installing-your-own-valhalla-server)
(tested with versions 3.4.x, 3.5.x and 3.6.x of Valhalla).

<img src="man/figures/map.png" align="center" width="500"/>

[code for the
map](https://gist.github.com/rCarto/8dfba641b807c20c8cbf72ef8ed0c9c5)

## Features

- `vl_route()`: Get route between locations.
- `vl_matrix()`: Get travel time matrices between points.
- `vl_locate()`: Get the nearest point on the road network.
- `vl_elevation()`: Get elevation data at given location(s).
- `vl_isochrone()`: Get isochrone polygons.
- `vl_optimized_route()`: Get optimized route between locations.
- `vl_status()`: Get information on Valhalla service.

## Installation

- Stable version from CRAN:

``` r
install.packages("valh")
```

- Development version from the r-universe.

``` r
install.packages("valh", repos = "https://riatelab.r-universe.dev")
```

## Demo

This is a short overview of the main features of `valh`. The dataset
used here is shipped with the package, it is a sample of 100 random
pharmacies in Berlin ([© OpenStreetMap
contributors](https://www.openstreetmap.org/copyright/en)) stored in a
[geopackage](https://www.geopackage.org/) file.

It demonstrates the use of `vl_matrix`, `vl_route` and `vl_elevation`
functions.

``` r
library(valh)
```

    ## Data: (c) OpenStreetMap contributors, ODbL 1.0 - http://www.openstreetmap.org/copyright

    ## Routing: Valhalla - valhalla.github.io/valhalla

``` r
library(sf)
```

    ## Linking to GEOS 3.13.1, GDAL 3.10.3, PROJ 9.6.0; sf_use_s2() is TRUE

``` r
pharmacy <- st_read(system.file("gpkg/apotheke.gpkg", package = "valh"), quiet = TRUE)
pharmacy <- pharmacy[1:6, ]
```

One of valhalla’s strengths is that it allows you to use dynamic costing
options at query time. For example, we can compare the travel time
between each pharmacy by bicycle:

- with the default bicycle parameters (type of bicycle “hybrid” with an
  average speed of 18 km/h and a propensity to use roads, alongside
  other vehicles, of 0.5 out of 1 - the default value),
- with the road bicycle parameters (type of bicycle “road” with an
  average speed of 25 km/h and a propensity to use roads, alongside
  other vehicles, of 1 out of 1).

These costing options for each costing model (‘auto’, ‘bicycle’, etc.)
are documented in [Valhalla’s
documentation](https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#costing-models).

``` r
default_bike <- vl_matrix(loc = pharmacy, costing = "bicycle")

road_bike <- vl_matrix(loc = pharmacy, costing = "bicycle",
                       costing_options = list(bicycle_type = "Road", use_roads = "1"))
```

The object returned by `vl_matrix` is a list with 4 elements:

- `sources`: origin point coordinates,
- `destinations`: destination point coordinates,
- `distances` : distance matrix between sources and destinations,
- `durations` : travel time matrix between sources and destinations.

``` r
default_bike$durations
```

    ##      1    2    3    4    5    6
    ## 1  0.0 45.8 76.9 35.7 17.7 32.4
    ## 2 46.5  0.0 86.7 29.5 42.7 75.4
    ## 3 72.9 88.3  0.0 62.2 59.1 76.2
    ## 4 33.0 29.6 62.0  0.0 20.7 55.8
    ## 5 18.8 44.3 61.3 23.2  0.0 35.4
    ## 6 32.2 75.5 75.7 60.4 34.6  0.0

``` r
road_bike$durations
```

    ##      1    2    3    4    5    6
    ## 1  0.0 33.1 51.5 25.2 13.2 21.8
    ## 2 33.1  0.0 61.3 21.6 30.2 51.9
    ## 3 50.1 62.8  0.0 43.6 41.5 53.3
    ## 4 23.5 21.9 43.4  0.0 15.5 38.8
    ## 5 12.6 31.2 42.3 15.7  0.0 23.9
    ## 6 20.6 51.8 51.7 40.3 23.7  0.0

We can see not only that travel times are different (which is to be
expected, given that we’ve changed the cyclist’s default speed), but
also that the path taken are different (as a consequence of the change
in preference for using roads rather than cycle paths).

``` r
default_bike$distances - road_bike$distances
```

    ##       1      2      3      4      5      6
    ## 1 0.000 -0.191  1.394  0.599  0.015  0.003
    ## 2 0.015  0.000 -0.002  0.007 -0.249  0.336
    ## 3 1.095 -0.228  0.000 -0.050  0.410  0.033
    ## 4 0.015 -0.188 -0.009  0.000 -0.260 -0.061
    ## 5 0.594 -0.170  0.420  0.599  0.000 -0.072
    ## 6 0.017 -0.167 -0.676  0.035  0.026  0.000

We now calculate a route between two points, by foot, using the
`vl_route` function and calculate the elevation profile of the returned
route, using the `vl_elevation` function.

``` r
p1 <- pharmacy[3, ]
p2 <- pharmacy[6, ]
route <- vl_route(p1, p2, costing = "pedestrian")
plot(st_geometry(route), main = "Route between 2 pharmacies")
plot(c(st_geometry(p1), st_geometry(p2)), pch = 21, cex = 2, add = TRUE)
```

![](man/figures/README-route-1.png)<!-- -->

``` r
# We transform the LineString to Point geometries
pts_route <- sf::st_cast(st_geometry(route), "POINT")

elev <- vl_elevation(loc = pts_route, sampling_dist = 100)
```

The object returned is an sf object with a point for each location where
the altitude has been sampled and with the attributes ‘distance’ (the
cumulative distance to the first point) and ‘height’ (the altitude).

We can use it to plot the elevation profile of the route.

``` r
plot(as.matrix(st_drop_geometry(elev)), type = "l", lwd = 2, ylim = c(20, 70), asp = 100,
     main = "Elevation Profile")
```

![](man/figures/README-elevation-1.png)<!-- -->

## Installing your own Valhalla server

`valh` uses the Valhalla demo server by default. The [Valhalla
documentation](https://valhalla.github.io/valhalla/#demo-server) states
that “usage of the demo server follows the usual fair-usage policy as
OSRM & Nominatim demo servers (somewhat enforced by [rate
limits](https://github.com/valhalla/valhalla/discussions/3373#discussioncomment-1644713))”.  
This means that if you want to use Valhalla for a large number of
requests, you will need to install it locally or on your own server.  
To that end, we have included a
[vignette](https://CRAN.R-project.org/package=valh/vignettes/install-valhalla.html)
showing how to install your own instance of Valhalla, either locally or
on a remote server, using Docker.

## Motivation & Alternatives

The package is designed to provide an easy-to-use interface to the
Valhalla routing service from R. Special care has been taken to support
multiple input formats, and the package treats `sf` objects as
first-class citizens in both input and output. Additionally, we have
tried to maintain a minimal number of dependencies.

This package offers an API that closely resembles that of the
[`osrm`](https://github.com/riatelab/osrm) package which provides an R
interface to the OSRM routing service.

Note that there are other packages that provide an interface to Valhalla
API from R :

- [valhallr](https://github.com/chris31415926535/valhallr/): This
  package is on CRAN. It provides access to some of Valhalla’s services
  (*height*, *locate* and *optimized route* are notably missing). It
  depends on a number of rather heavy packages and it does not allow
  `sf` objects as input.
- [rvalhalla](https://github.com/Robinlovelace/rvalhalla): This package
  is not on CRAN. Although it can provide access to several Valhalla
  services, it only makes it easy to use two of them (*route* and
  *sources_to_target*). It does not accept `sf` objects as input.

## Community Guidelines

One can contribute to the package through [pull
requests](https://github.com/riatelab/valh/pulls) and report issues or
ask questions [here](https://github.com/riatelab/valh/issues). See the
[CONTRIBUTING.md](https://github.com/riatelab/valh/blob/master/CONTRIBUTING.md)
file for detailed instructions.
