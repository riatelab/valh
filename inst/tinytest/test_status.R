if(demo_server){
  status <- vl_status(verbose = FALSE)
  wait()
  expect_equal(length(status), 3)
  expect_equal(names(status), c("version", "tileset_last_modified", "available_actions"))
  status_v <- vl_status(verbose = TRUE)
  expect_true(length(status_v) > 3)
}
