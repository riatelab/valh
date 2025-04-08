
# valh

![CRAN](https://www.r-pkg.org/badges/version/valh) [![R build
status](https://github.com/riatelab/valh/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/riatelab/valh/actions)
[![codecov](https://codecov.io/gh/riatelab/valh/graph/badge.svg)](https://app.codecov.io/gh/riatelab/valh)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

***Interface Between R and the OpenStreetMap-Based Routing Service
[Valhalla](https://valhalla.github.io/valhalla/)***

## Description

[Valhalla](https://valhalla.github.io/valhalla/) is a routing service
that is based on OpenStreetMap data. This package provides an interface
to the Valhalla API from R. It allows you to query the Valhalla API for
routes, isochrones, time-distance matrices, nearest point on the road
network, and elevation data.

This package relies on the usage of a running Valhalla service (tested
with v3.4.x-3.5.x of Valhalla).

## Features

- `vl_route()`: Get route between locations.
- `vl_matrix()`: Get travel time matrices between points.
- `vl_locate()`: Get the nearest point on the road network.
- `vl_elevation()`: Get elevation data at given location(s).
- `vl_isochrone()`: Get isochrone polygons.
- `vl_optimized_route()`: Get optimized route between locations.
- `vl_status()`: Get information on Valhalla service.

## Installation

- Development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("riatelab/valh")
```

<!-- - Stable version from CRAN: -->
<!-- ```{r} -->
<!-- #| eval: false -->
<!-- install.packages("valh") -->
<!-- ``` -->
<!-- ## Demo -->
<!-- This is a short overview of the main features of `valh`. The dataset -->
<!-- used here is shipped with the package, it is a sample of 100 random -->
<!-- pharmacies in Berlin ([© OpenStreetMap -->
<!-- contributors](https://www.openstreetmap.org/copyright/en)) stored in a -->
<!-- [geopackage](https://www.geopackage.org/) file. -->
<!-- - `vl_matrix()` gives access to the *sources_to_targets* Valhalla service. In this -->
<!--   example we use this function to get the median time needed to access ... -->
<!-- - `vl_route()` is used to compute the shortest route between two -->
<!--   points. Here we compute the shortest route between ... -->
<!-- - `vl_optimized_route()` can be used to resolve the travelling salesman problem, -->
<!--   it gives the shortest trip between a set of unordered points. In this -->
<!--   example we want to obtain the shortest trip between ... -->
<!-- - `vl_locate()` gives access to the *locate* Valhalla service. It returns -->
<!--   the nearest points on the street network from any point. Here we will -->
<!--   get the nearest point on the network from a couple of coordinates. -->
<!-- - `vl_isochrone()` computes areas that are reachable within a given -->
<!--   time span from a point and returns the reachable regions as polygons. -->
<!--   These areas of equal travel time are called isochrones. Here we -->
<!--   compute the isochrones from a specific point defined by its longitude -->
<!--   and latitude. -->

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
  package is on CRAN, but only allows you to access to some Valhalla
  services (*height*, *locate* and *optimized route* are notably
  absent). In addition, it calls on many heavy dependencies to install,
  whereas `valh` is particularly light on dependencies. Finally, it
  doesn’t allow you to work directly with `sf` objects as input.

- [rvalhalla](https://github.com/Robinlovelace/rvalhalla): This package
  is not on the CRAN, and while it provides access to various Valhalla
  services, it only does the heavy lifting needed to easily use the data
  for two of the services (*route* and *sources_to_target*). In
  addition, it doesn’t allow you to work directly with `sf` objects as
  input.

## Community Guidelines

One can contribute to the package through [pull
requests](https://github.com/riatelab/valh/pulls) and report issues or
ask questions [here](https://github.com/riatelab/valh/issues). See the
[CONTRIBUTING.md](https://github.com/riatelab/valh/blob/master/CONTRIBUTING.md)
file for detailed instructions.
