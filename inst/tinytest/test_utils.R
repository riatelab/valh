# base_url
address_1 <- "https://valhalla1.openstreetmap.de/"
address_2 <- "https://valhalla1.openstreetmap.de"
address_3 <- "htps/valhalla1.openstreetmap.de/"

expect_identical(valh:::base_url(address_1), address_1)
expect_identical(valh:::base_url(address_2), address_1)
expect_error(valh:::base_url(address_3))

# clean_coord
expect_identical(valh:::clean_coord(45.123456789), "45.12346")
