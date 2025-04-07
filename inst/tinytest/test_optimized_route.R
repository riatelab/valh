if(demo_server){
  options(valh.server = valh.server)
  expect_silent(x <- vl_optimized_route(loc = x_sf[1:6, ]))
  expect_silent(y <- vl_optimized_route(loc = x_df[1:6, ],
                                        end_at_start = TRUE,
                                        costing = "bicycle",
                                        costing_options = list(bicycle_type = "Mountain")))
  expect_inherits(x$shape, "sf")
  expect_true(nrow(x$shape) == 5)
  expect_identical(st_crs(x$shape), st_crs(x_sf))
  expect_identical(names(x$summary), c("duration", "distance", "has_toll",
                                       "has_highway", "has_time_restrictions",
                                       "has_ferry"))

  expect_inherits(y$shape, "sf")
  expect_true(nrow(y$shape) == 6)
  expect_identical(st_crs(y$shape), st_crs(4326))
  expect_identical(names(y$summary), c("duration", "distance", "has_toll",
                                       "has_highway", "has_time_restrictions",
                                       "has_ferry"))
}
