# geom
expect_error(valh:::input_table(x = x_sfc_l, "loc"))
# input_table_out <- valh:::input_table(x = x_sfc, "loc")
# saveRDS(input_table_out, "inst/tinytest/input_table_out_sfc.rds")
expect_identical(valh:::input_table(x = x_sfc, "loc"), readRDS("input_table_out_sfc.rds"))
# input_table_out <- valh:::input_table(x = x_sf, "loc")
# saveRDS(input_table_out, "inst/tinytest/input_table_out_sf.rds")
expect_identical(valh:::input_table(x = x_sf, "loc"), readRDS("input_table_out_sf.rds"))

# data.frame
er_x_df <- x_df
er_x_df[1, 2] <- "A"
expect_error(valh:::input_table(er_x_df, "loc"))
# input_table_out <- valh:::input_table(x = x_df, "loc")
# saveRDS(input_table_out, "inst/tinytest/input_table_out_df.rds")
expect_identical(valh:::input_table(x = x_df, "loc"), readRDS("input_table_out_df.rds"))

# matrix
er_x_m <- x_m
er_x_m[1, 2] <- "A"
expect_error(input_table(er_x_m, "loc"))
# input_table_out <- valh:::input_table(x = x_m, "loc")
# saveRDS(input_table_out, "inst/tinytest/input_table_out_m.rds")
expect_identical(valh:::input_table(x = x_m, "loc"), readRDS("input_table_out_m.rds"))

# else
expect_error(valh:::input_table(plot, "loc"))

