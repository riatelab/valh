if(demo_server){
  options(valh.server = valh.server)
  expect_error(vl_isochrone(x_v))
  expect_error(vl_isochrone(x_v, times = c(0,15,20,30)))
  expect_error(vl_isochrone(x_v, times = c(15,20,30,40,50)))
  expect_error(vl_isochrone(x_v, distances = c(0, 15,20,30)))
  expect_error(vl_isochrone(x_v, distances = c(15,20,30,40,50)))
  expect_error(vl_isochrone(x_v, times = c(15,20,30), distances = c(15,20,30)))
  expect_silent(x <- vl_isochrone(x_v,times = c(10,15,20,25),
                                  costing = "bicycle",
                                  costing_options = list(bicycle_type = "Road")))
  expect_inherits(x, "sf")
  expect_true(nrow(x)==4)

  x <- vl_isochrone(x_sf[1,], distances = c(15,20,30,40))
  expect_inherits(x, "sf")
  expect_true(nrow(x)==4)
  expect_identical(st_crs(x), st_crs(x_sf))

}
