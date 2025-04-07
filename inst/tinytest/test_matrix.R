if(demo_server){
  options(valh.server = valh.server)
  x <- vl_matrix(src = x_df[1:10, ], dst = x_df[11:20, ])
  expect_true(length(x)==4)
  expect_equal(dim(x$sources), c(10,2))
  expect_equal(dim(x$destinations), c(10,2))
  expect_equal(dim(x$durations), c(10,10))
  expect_equal(dim(x$distances), c(10,10))
  expect_silent(y <- vl_matrix(loc = x_sf[1:10,],
                               costing = "bicycle",
                               costing_options = list(bicycle_type = "Road")))
  expect_true(max(diag(y$durations)) == 0)
  expect_identical(row.names(y$durations), row.names(x_sf[1:10, ]))
}
