if(demo_server){
  options(valh.server = valh.server)
  loc <- vl_elevation(x_v)
  expect_inherits(loc, "sf")
  loc <- vl_elevation(x_sfc[1])
  expect_inherits(loc, "sf")
  expect_identical(st_crs(loc), st_crs(x_sfc))

  loc <- vl_elevation(x_sf[1:10, ])
  expect_inherits(loc, "sf")
  expect_true(nrow(loc)==10)
  expect_identical(st_crs(loc), st_crs(x_sf))

  loc <- vl_elevation(x_df[1:10, ])
  expect_inherits(loc, "sf")
  expect_true(nrow(loc)==10)
  expect_inherits(loc, "sf")
  expect_identical(st_crs(loc), st_crs(4326))

  loc <- vl_elevation(x_sf[1:2, ], sampling_dist = 500)
  expect_inherits(loc, "sf")
  expect_true(nrow(loc)==21)
}

