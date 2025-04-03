if(demo_server){
  A <- vl_matrix(src = x_df[1:10, ], dst = x_df[11:20, ])
  expect_true(length(A)==4)
  expect_equal(dim(A$sources), c(10,2))
  expect_equal(dim(A$destinations), c(10,2))
  expect_equal(dim(A$durations), c(10,10))
  expect_equal(dim(A$distances), c(10,10))
  wait()
  expect_silent(B <- vl_matrix(loc = x_sf[1:10,],
                               costing = "bicycle",
                               costing_options = list(bicycle_type = "Road")))
  wait()
  expect_true(max(diag(B$durations)) == 0)
  expect_identical(row.names(B$durations), row.names(x_sf[1:10, ]))
}
