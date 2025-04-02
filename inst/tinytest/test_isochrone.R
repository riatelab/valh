# if(demo_server){
#   expect_error(vl_isochrone(x_v))
#   expect_error(vl_isochrone(x_v, times = c(0,15,20,30), distances = c(0,50,500)))
#   r <- vl_isochrone(x_v,times = c(5,10,15,20, 25))
#
#   mapsf::mf_map(r)
#    , costing = "auto")
#   wait()
#   expect_inherits(loc, "sf")
#   loc <- vl_isochrone(x_sfc[1])
#   wait()
#   expect_inherits(loc, "sf")
#   expect_identical(st_crs(loc), st_crs(x_sfc))
#
#   loc <- vl_isochrone(x_sf[1:10, ])
#   wait()
#   expect_inherits(loc, "sf")
#   expect_true(nrow(loc)==10)
#   expect_identical(st_crs(loc), st_crs(x_sf))
#
#   loc <- vl_isochrone(x_df[1:10, ])
#   wait()
#   expect_inherits(loc, "sf")
#   expect_true(nrow(loc)==10)
#   expect_inherits(loc, "sf")
#   expect_identical(st_crs(loc), st_crs(4326))
#
#   loc <- vl_isochrone(x_sf[1:2, ], sampling_dist = 500)
#   wait()
#   expect_inherits(loc, "sf")
#   expect_true(nrow(loc)==21)
# }
#
#
#
# pt1 <- apotheke.df[1, c("lon", "lat")]
# iso1 <- vl_isochrone(loc = pt1, distances = c(3, 6, 9, 12), costing = "auto")
