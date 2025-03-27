# valh

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

***Interface Between R and the OpenStreetMap-Based Routing Service
[Valhalla](http://valhalla.github.io/)***

## Description

[Valhalla](http://valhalla.github.io/) is a routing service that is based on OpenStreetMap data.
This package provides an interface to the Valhalla API from R.
It allows you to query the Valhalla API for routes, isochrones, time-distance matrices,
nearest point on the road network, and elevation data.

This package relies on the usage of a running Valhalla service (tested with v3.4.x-3.5.x of Valhalla).

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

```R
# install.packages("remotes")
remotes::install_github("riatelab/valh")
```

- Stable version from CRAN:

```R
install.packages("valh")
```

## Motivation & Alternatives

The package is developed to provide an interface to the Valhalla routing service from R
that works well with `sf` objects as input (but not only: in `valh` a special attention is
given to supporting multiple input formats) and is easy to use.

This package offers an API that closely resembles that of the [`osrm`](https://github.com/riatelab/osrm)
package which provides an R interface to the OSRM routing service.

Note that there are other packages that provide an interface to Valhalla API from R :

- https://github.com/chris31415926535/valhallr/: This package is on CRAN,
  but does not allow access to various Valhalla functions (notably the “height”, “locate”
  and “optimized route” services). In addition, it calls on many heavy dependencies to install,
  whereas our `valh` is particularly light on dependencies.
  Finally, it doesn't allow you to work directly with `sf` objects as input.

- https://github.com/Robinlovelace/rvalhalla: This package is not on the CRAN, and while it
  provides access to the various Valhalla services, it only does the heavy lifting needed to
  easily use the data for two of the services (route and sources_to_target). Nor does it allow
  you to work directly with `sf` objects as input.

## Community Guidelines

One can contribute to the package through [pull requests](https://github.com/riatelab/valh/pulls) and
report issues or ask questions [here](https://github.com/riatelab/valh/issues).
See the [CONTRIBUTING.md](https://github.com/riatelab/valh/blob/master/CONTRIBUTING.md)
file for detailed instructions.
