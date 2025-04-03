# Ensure that the input is a valid URL
# and add the missing trailing slash if not present.
base_url <- function(url) {
  if (!grepl("^http(s)?://", url)) {
    stop("Invalid URL", call. = FALSE)
  }
  if (!endsWith(x = url, "/")) {
    url <- paste0(url, "/")
  }
  return(url)
}

clean_coord <- function(x) {
  format(round(as.numeric(x), 5),
    scientific = FALSE, justify = "none",
    trim = TRUE, nsmall = 5, digits = 5
  )
}

test_http_error <- function(r) {
  if (r$status_code >= 400) {
    if (is.na(r$type)) {
      stop(
        sprintf(
          "Valhalla API request failed [%s]\n%s",
          r$status_code, rawToChar(r$content)
        ),
        call. = FALSE
      )
    }
    if (substr(r$type, 1, 16) != "application/json") {
      stop(
        sprintf(
          "Valhalla API request failed [%s]",
          r$status_code
        ),
        call. = FALSE
      )
    } else {
      rep <- jsonlite::parse_json(rawToChar(r$content))
      stop(
        sprintf(
          "Valhalla API request returned an error [%s]\n%s\n%s",
          r$status_code,
          rep$error_code,
          rep$error
        ),
        call. = FALSE
      )
    }
  }
  return(NULL)
}

get_results <- function(url) {
  req_handle <- curl::new_handle(verbose = FALSE)
  curl::handle_setopt(req_handle, useragent = "valh_R_package")
  e <- try(
    {
      r <- curl::curl_fetch_memory(utils::URLencode(url), handle = req_handle)
    },
    silent = TRUE
  )
  if (inherits(e, "try-error")) {
    stop(e, call. = FALSE)
  }
  test_http_error(r)
  return(r)
}

input_route <- function(x, id, single = TRUE, all.ids = FALSE) {
  # test various cases (vector, data.frame, sf or sfc)
  oprj <- NA
  if (single) {
    if (is.vector(x)) {
      if (length(x) == 2 && is.numeric(x)) {
        if (x[1] > 180 || x[1] < -180 || x[2] > 90 || x[2] < -90) {
          stop(
            paste0(
              "longitude is bounded by the interval [-180, 180], ",
              "latitude is bounded by the interval [-90, 90]"
            ),
            call. = FALSE
          )
        }
        lon <- clean_coord(x[1])
        lat <- clean_coord(x[2])
        return(list(id = id, lon = lon, lat = lat, oprj = oprj))
      } else {
        stop(
          paste0(
            '"', id, '" should be a numeric vector of length 2, ',
            "i.e., c(lon, lat)."
          ),
          call. = FALSE
        )
      }
    }
    if (inherits(x = x, what = c("sfc", "sf"))) {
      oprj <- sf::st_crs(x)
      if (length(sf::st_geometry(x)) > 1) {
        message(paste0('Only the first row/element of "', id, '" is used.'))
      }
      if (inherits(x, "sfc")) {
        x <- x[1]
        idx <- id
      } else {
        x <- x[1, ]
        idx <- row.names(x)
      }
      if (sf::st_geometry_type(x, by_geometry = FALSE) != "POINT") {
        stop(paste0('"', id, '" geometry should be of type POINT.'),
          call. = FALSE
        )
      }
      x <- sf::st_transform(x = x, crs = 4326)
      coords <- sf::st_coordinates(x)
      lon <- clean_coord(coords[, 1])
      lat <- clean_coord(coords[, 2])
      return(list(id = idx, lon = lon, lat = lat, oprj = oprj))
    }
    if (inherits(x = x, what = c("data.frame", "matrix"))) {
      if (nrow(x) > 1) {
        message(paste0('Only the first row of "', id, '" is used.'))
        x <- x[1, , drop = FALSE]
      }
      idx <- row.names(x)
      if (is.null(idx)) {
        idx <- id
      }
      x <- unlist(x)
      if (length(x) == 2 && is.numeric(x)) {
        lon <- clean_coord(x[1])
        lat <- clean_coord(x[2])
        return(list(id = idx, lon = lon, lat = lat, oprj = oprj))
      } else {
        stop(paste0('"', id, '" should contain coordinates.'),
          call. = FALSE
        )
      }
    } else {
      stop(
        paste0(
          '"', id, '" should be a vector of coordinates, ',
          "a data.frame or a matrix ",
          "of coordinates, an sfc POINT object or an ",
          "sf POINT object."
        ),
        call. = FALSE
      )
    }
  } else {
    if (inherits(x = x, what = c("sfc", "sf"))) {
      oprj <- sf::st_crs(x)
      lx <- length(sf::st_geometry(x))
      if (lx < 2) {
        stop('"loc" should have at least 2 rows or elements.',
          call. = FALSE
        )
      }
      type <- sf::st_geometry_type(x, by_geometry = FALSE)
      type <- as.character(unique(type))
      if (length(type) > 1 || type != "POINT") {
        stop('"loc" geometry should be of type POINT', call. = FALSE)
      }
      if (inherits(x, "sfc")) {
        id1 <- "src"
        id2 <- "dst"
        if (all.ids) {
          rn <- 1:lx
        }
      } else {
        rn <- row.names(x)
        id1 <- rn[1]
        id2 <- rn[lx]
      }
      x <- sf::st_transform(x = x, crs = 4326)
      coords <- sf::st_coordinates(x)
      lon <- clean_coord(coords[, 1])
      lat <- clean_coord(coords[, 2])
      if (!all.ids) {
        return(list(id1 = id1, id2 = id2, lon = lon, lat = lat, oprj = oprj))
      } else {
        return(list(id = rn, lon = lon, lat = lat, oprj = oprj))
      }
    }
    if (inherits(x = x, what = c("data.frame", "matrix"))) {
      lx <- nrow(x)
      if (lx < 2) {
        stop('"loc" should have at least 2 rows.', call. = FALSE)
      }
      if (ncol(x) == 2 && is.numeric(x[, 1, drop = TRUE]) && is.numeric(x[, 2, drop = TRUE])) {
        lon <- clean_coord(x[, 1, drop = TRUE])
        lat <- clean_coord(x[, 2, drop = TRUE])
        rn <- row.names(x)
        if (is.null(rn)) {
          rn <- 1:lx
        }
        id1 <- rn[1]
        id2 <- rn[lx]
        if (!all.ids) {
          return(list(id1 = id1, id2 = id2, lon = lon, lat = lat, oprj = oprj))
        } else {
          return(list(id = rn, lon = lon, lat = lat, oprj = oprj))
        }
      } else {
        stop(paste0('"loc" should contain coordinates.'),
          call. = FALSE
        )
      }
    } else {
      stop(
        paste0(
          '"loc" should be ',
          "a data.frame or a matrix ",
          "of coordinates, an sfc POINT object or an ",
          "sf POINT object."
        ),
        call. = FALSE
      )
    }
  }
}

input_locate <- function(x) {
  oprj <- NA
  if (is.vector(x)) {
    if (length(x) == 2 && is.numeric(x)) {
      if (x[1] > 180 || x[1] < -180 || x[2] > 90 || x[2] < -90) {
        stop(
          paste0(
            "longitude is bounded by the interval [-180, 180], ",
            "latitude is bounded by the interval [-90, 90]"
          ),
          call. = FALSE
        )
      }
      lon <- clean_coord(x[1])
      lat <- clean_coord(x[2])
      return(list(lon = lon, lat = lat, oprj = oprj))
    } else {
      stop('"loc" should be a numeric vector of length 2, i.e., c(lon, lat).',
        call. = FALSE
      )
    }
  }
  if (inherits(x = x, what = c("sfc", "sf"))) {
    oprj <- sf::st_crs(x)
    lx <- length(sf::st_geometry(x))
    type <- sf::st_geometry_type(x, by_geometry = FALSE)
    type <- as.character(unique(type))
    if (length(type) > 1 || type != "POINT") {
      stop('"loc" geometry should be of type POINT', call. = FALSE)
    }
    x <- sf::st_transform(x = x, crs = 4326)
    coords <- sf::st_coordinates(x)
    lon <- clean_coord(coords[, 1])
    lat <- clean_coord(coords[, 2])
    return(list(lon = lon, lat = lat, oprj = oprj))
  }
  if (inherits(x = x, what = c("data.frame", "matrix"))) {
    lx <- nrow(x)
    if (ncol(x) == 2 && is.numeric(x[, 1, drop = TRUE]) && is.numeric(x[, 2, drop = TRUE])) {
      lon <- clean_coord(x[, 1, drop = TRUE])
      lat <- clean_coord(x[, 2, drop = TRUE])
      return(list(lon = lon, lat = lat, oprj = oprj))
    } else {
      stop(paste0('"loc" should contain coordinates.'),
        call. = FALSE
      )
    }
  } else {
    stop(
      paste0(
        '"loc" should be a vector of coordinates, ',
        "a data.frame or a matrix ",
        "of coordinates, an sfc POINT object or an ",
        "sf POINT object."
      ),
      call. = FALSE
    )
  }
}

input_table <- function(x, id) {
  if (inherits(x = x, what = c("sfc", "sf"))) {
    lx <- length(sf::st_geometry(x))
    type <- sf::st_geometry_type(x, by_geometry = TRUE)
    type <- as.character(unique(type))
    if (length(type) > 1 || type != "POINT") {
      stop(paste0('"', id, '" geometry should be of type POINT.'),
        call. = FALSE
      )
    }
    if (inherits(x, "sfc")) {
      idx <- 1:lx
    } else {
      idx <- row.names(x)
    }
    x <- sf::st_transform(x = x, crs = 4326)
    coords <- sf::st_coordinates(x)
    x <- data.frame(
      id = idx,
      lon = clean_coord(coords[, 1]),
      lat = clean_coord(coords[, 2])
    )
    return(x)
  }
  if (inherits(x = x, what = c("data.frame", "matrix"))) {
    lx <- nrow(x)
    if (ncol(x) == 2 && is.numeric(x[, 1, drop = TRUE]) && is.numeric(x[, 2, drop = TRUE])) {
      rn <- row.names(x)
      if (is.null(rn)) {
        rn <- 1:lx
      }

      x <- data.frame(
        id = rn,
        lon = clean_coord(x[, 1, drop = TRUE]),
        lat = clean_coord(x[, 2, drop = TRUE])
      )
      return(x)
    } else {
      stop(paste0('"', id, '" should contain coordinates.'),
        call. = FALSE
      )
    }
  } else {
    stop(
      paste0(
        '"', id, '" should be ',
        "a data.frame or a matrix ",
        "of coordinates, an sfc POINT object or an ",
        "sf POINT object."
      ),
      call. = FALSE
    )
  }
}
