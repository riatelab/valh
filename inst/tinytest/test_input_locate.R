# vector
expect_error(valh:::input_locate(x = c(35,"35")))
expect_error(valh:::input_locate(x = c(35, 35, 35)))
expect_error(valh:::input_locate(x = c(35, 195)))
# input_locate_out_v <- valh:::input_locate(x = x_v)
# saveRDS(input_locate_out_v, "inst/tinytest/input_locate_out_v.rds")
expect_identical(valh:::input_locate(x = x_v), readRDS("input_locate_out_v.rds"))

# geom
expect_error(valh:::input_locate(x = x_sfc_l))
# input_locate_out <- valh:::input_locate(x = x_sfc)
# saveRDS(input_locate_out, "inst/tinytest/input_locate_out_sfc.rds")
expect_identical(valh:::input_locate(x = x_sfc), readRDS("input_locate_out_sfc.rds"))
# input_locate_out <- valh:::input_locate(x = x_sf)
# saveRDS(input_locate_out, "inst/tinytest/input_locate_out_sf.rds")
expect_identical(valh:::input_locate(x = x_sf), readRDS("input_locate_out_sf.rds"))

# data.frame
er_x_df <- x_df
er_x_df[1, 2] <- "A"
expect_error(valh:::input_locate(er_x_df))
# input_locate_out <- valh:::input_locate(x = x_df)
# saveRDS(input_locate_out, "inst/tinytest/input_locate_out_df.rds")
expect_identical(valh:::input_locate(x = x_df), readRDS("input_locate_out_df.rds"))

# matrix
er_x_m <- x_m
er_x_m[1, 2] <- "A"
expect_error(input_locate(er_x_m))
# input_locate_out <- valh:::input_locate(x = x_m)
# saveRDS(input_locate_out, "inst/tinytest/input_locate_out_m.rds")
expect_identical(valh:::input_locate(x = x_m), readRDS("input_locate_out_m.rds"))

# else
expect_error(valh:::input_locate(plot))

