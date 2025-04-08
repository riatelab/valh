# Single input/output
# incorrect vector
expect_error(valh:::input_route(x = c(35,"35"),
                                id = "src",
                                single = TRUE,
                                all.ids = FALSE))
expect_error(valh:::input_route(x = c(200,350),
                                id = "src",
                                single = TRUE,
                                all.ids = FALSE))
# multiline object
expect_message(valh:::input_route(x = x_sfc,
                                  id = "src",
                                  single = TRUE,
                                  all.ids = FALSE))
expect_message(valh:::input_route(x = x_df,
                                  id = "src",
                                  single = TRUE,
                                  all.ids = FALSE))
# x not a point
expect_error(valh:::input_route(x = st_cast(x_sf[1,], "MULTIPOINT"),
                                id = "src",
                                single = TRUE,
                                all.ids = FALSE))
# incorrect df
expect_error(valh:::input_route(x = st_drop_geometry(x_sf[1,]),
                                id = "src",
                                single = TRUE,
                                all.ids = FALSE))
# wrong input type
expect_error(valh:::input_route(x = st_crs(x_sf),
                                id = "src",
                                single = TRUE,
                                all.ids = FALSE))

# Multi input/output
# too short input
expect_error(valh:::input_route(x = x_sf[1,],
                                id = "loc",
                                single = FALSE,
                                all.ids = FALSE))
expect_error(valh:::input_route(x = x_df[1,,drop = FALSE],
                                id = "loc",
                                single = FALSE,
                                all.ids = FALSE))

# x not a point
expect_error(valh:::input_route(x = st_cast(x_sf[1:2,], "MULTIPOINT"),
                                id = "loc",
                                single = FALSE,
                                all.ids = FALSE))

# incorrect df
expect_error(valh:::input_route(x = st_drop_geometry(x_sf[1:2,]),
                                id = "loc",
                                single = FALSE,
                                all.ids = FALSE))
# wrong input type
expect_error(valh:::input_route(x = st_crs(x_sf),
                                id = "loc",
                                single = FALSE,
                                all.ids = FALSE))



######## SINGLE
# input vector
# input_route_out_v <- valh:::input_route(x = x_v,
#                                         id = "src",
#                                         single = TRUE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_v, "inst/tinytest/input_route_out_v.rds")
expect_identical(valh:::input_route(x = x_v,
                                    id = "src",
                                    single = TRUE,
                                    all.ids = FALSE),
                 readRDS("input_route_out_v.rds"))

# input data.frame
# input_route_out_df <- valh:::input_route(x = x_df[1,],
#                                         id = "src",
#                                         single = TRUE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_df, "inst/tinytest/input_route_out_df.rds")
expect_identical(valh:::input_route(x = x_df[1, ],
                                    id = "src",
                                    single = TRUE,
                                    all.ids = FALSE),
                 readRDS("input_route_out_df.rds"))

# input matrix
# input_route_out_m <- valh:::input_route(x = x_m[1,,drop = F],
#                                         id = "src",
#                                         single = TRUE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_m, "inst/tinytest/input_route_out_m.rds")
expect_identical(valh:::input_route(x =  x_m[1,,drop = F],
                                    id = "src",
                                    single = TRUE,
                                    all.ids = FALSE),
                 readRDS("input_route_out_m.rds"))

# input sfc
# input_route_out_sfc <- valh:::input_route(x = x_sfc[1],
#                                         id = "src",
#                                         single = TRUE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_sfc, "inst/tinytest/input_route_out_sfc.rds")
target <- readRDS("input_route_out_sfc.rds")
expect_silent(current <- valh:::input_route(x = x_sfc[1], id = "src", single = TRUE, all.ids = FALSE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)

# input sf
# input_route_out_sf <- valh:::input_route(x = x_sf[1,],
#                                         id = "src",
#                                         single = TRUE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_sf, "inst/tinytest/input_route_out_sf.rds")
target <- readRDS("input_route_out_sf.rds")
expect_silent(current <- valh:::input_route(x = x_sf[1, ], id = "src", single = TRUE, all.ids = FALSE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)


######## MULTI
# input data.frame
# input_route_out_df_m <- valh:::input_route(x = x_df[1:4,],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_df_m, "inst/tinytest/input_route_out_df_m.rds")
expect_identical(valh:::input_route(x = x_df[1:4, ],
                                    id = "loc",
                                    single = FALSE,
                                    all.ids = FALSE),
                 readRDS("input_route_out_df_m.rds"))

# input matrix
# input_route_out_m_m <- valh:::input_route(x = x_m[1:4,],
#                                         id = "src",
#                                         single = FALSE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_m_m, "inst/tinytest/input_route_out_m_m.rds")
expect_identical(valh:::input_route(x =  x_m[1:4,],
                                    id = "loc",
                                    single = FALSE,
                                    all.ids = FALSE),
                 readRDS("input_route_out_m_m.rds"))

# input sfc
# input_route_out_sfc_m <- valh:::input_route(x = x_sfc[1:4],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_sfc_m, "inst/tinytest/input_route_out_sfc_m.rds")
target <- readRDS("input_route_out_sfc_m.rds")
expect_silent(current <- valh:::input_route(x = x_sfc[1:4], id = "src", single = FALSE, all.ids = FALSE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)




# input sf
# input_route_out_sf_m <- valh:::input_route(x = x_sf[1:4,],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = FALSE)
# saveRDS(input_route_out_sf_m, "inst/tinytest/input_route_out_sf_m.rds")
target <- readRDS("input_route_out_sf_m.rds")
expect_silent(current <- valh:::input_route(x = x_sf[1:4, ], id = "src", single = FALSE, all.ids = FALSE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)



######## MULTI + all.ids
# input data.frame
# input_route_out_df_m_id <- valh:::input_route(x = x_df[1:4,],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = TRUE)
# saveRDS(input_route_out_df_m_id, "inst/tinytest/input_route_out_df_m_id.rds")
expect_identical(valh:::input_route(x = x_df[1:4, ],
                                    id = "loc",
                                    single = FALSE,
                                    all.ids = TRUE),
                 readRDS("input_route_out_df_m_id.rds"))

# input matrix
# input_route_out_m_m_id <- valh:::input_route(x = x_m[1:4,],
#                                         id = "src",
#                                         single = FALSE,
#                                         all.ids = TRUE)
# saveRDS(input_route_out_m_m_id, "inst/tinytest/input_route_out_m_m_id.rds")
expect_identical(valh:::input_route(x =  x_m[1:4,],
                                    id = "loc",
                                    single = FALSE,
                                    all.ids = TRUE),
                 readRDS("input_route_out_m_m_id.rds"))

# input sfc
# input_route_out_sfc_m_id <- valh:::input_route(x = x_sfc[1:4],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = TRUE)
# saveRDS(input_route_out_sfc_m_id, "inst/tinytest/input_route_out_sfc_m_id.rds")
target <- readRDS("input_route_out_sfc_m_id.rds")
expect_silent(current <- valh:::input_route(x = x_sfc[1:4], id = "loc", single = FALSE, all.ids = TRUE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)


# input sf
# input_route_out_sf_m_id <- valh:::input_route(x = x_sf[1:4,],
#                                         id = "loc",
#                                         single = FALSE,
#                                         all.ids = TRUE)
# saveRDS(input_route_out_sf_m_id, "inst/tinytest/input_route_out_sf_m_id.rds")
target <- readRDS("input_route_out_sf_m_id.rds")
expect_silent(current <- valh:::input_route(x = x_sf[1:4, ], id = "loc", single = FALSE, all.ids = TRUE))
expect_identical(current$lon, target$lon)
expect_identical(current$oprj$input, target$oprj$input)

