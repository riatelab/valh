if(demo_server){
  options(valh.server = valh.server)
  loc <- vl_locate(x_v, costing = "bicycle", costing_options = list(cycling_speed = 190, bicycle_type = "road"))
  expect_inherits(loc, "sf")
  loc <- vl_locate(x_sfc[1])
  expect_inherits(loc, "sf")
  expect_identical(st_crs(loc), st_crs(x_sfc))

  loc <- vl_locate(x_sf[1:10, ])
  expect_inherits(loc, "list")
  expect_true(length(loc)==10)
  expect_inherits(loc[[1]], "sf")
  expect_identical(st_crs(loc[[1]]), st_crs(x_sf))

  loc <- vl_locate(x_df[1:10, ])
  expect_inherits(loc, "list")
  expect_true(length(loc)==10)
  expect_inherits(loc[[1]], "sf")
  expect_identical(st_crs(loc[[1]]), st_crs(4326))
}
