if(demo_server){
  options(valh.server = valh.server)
  expect_silent(x <- vl_route(src = x_df[1, ], dst = x_df[2, ]))
  expect_inherits(x, "sf")
  expect_true(nrow(x) == 1)
  expect_identical(st_crs(x), st_crs(4326))
  expect_silent(y <- vl_route(src = x_sf[1, ], dst = x_sf[2, ],
                               costing = "bicycle",
                               costing_options = list(bicycle_type = "Road")))
  expect_inherits(y, "sf")
  expect_true(nrow(y) == 1)
  expect_identical(st_crs(y), st_crs(x_sf))
  expect_silent(z <- vl_route(loc = x_sf[1:5, ],
                              costing = "bicycle",
                              costing_options = list(bicycle_type = "Road")))
  expect_inherits(z, "sf")
  expect_true(nrow(z) == 1)
  expect_identical(st_crs(z), st_crs(x_sf))
}
