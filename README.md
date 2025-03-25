# valh

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

***Interface Between R and the OpenStreetMap-Based Routing Service
[Valhalla](http://valhalla.github.io/)***

## Description

[Valhalla](http://valhalla.github.io/) is a routing service that is based on OpenStreetMap data.
This package provides an interface to the Valhalla API from R.
It allows you to query the Valhalla API for routes, isochrones, time-distance matrices, nearest point on the road network, and elevation data.

This package relies on the usage of a running Valhalla service (tested with v3.4.x-3.5.x of Valhalla).

## Features

- `vl_route()`: Get route between locations.
- `vl_locate()`: Get the nearest point on the road network.
- `vl_elevation()`: Get elevation data at given location(s).
- `vl_isochrone()`: Get isochrone polygons.
- ...

## Installation

- Development version from GitHub:

```R
# install.packages("remotes")
remotes::install_github("riatelab/val")
```

- Stable version from CRAN:

```R
install.packages("val")
```

## Community Guidelines

One can contribute to the package through [pull requests](https://github.com/riatelab/val/pulls) and
report issues or ask questions [here](https://github.com/riatelab/val/issues).
See the [CONTRIBUTING.md](https://github.com/riatelab/val/blob/master/CONTRIBUTING.md)
file for detailed instructions.
