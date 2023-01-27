find_package(miniz CONFIG REQUIRED)
set(MINIZ_LIBRARIES miniz::miniz)

find_package(unofficial-libsquish CONFIG REQUIRED)
set(LIBSQUISH_LIBRARIES unofficial::libsquish::squish)

find_package(tinyexr CONFIG REQUIRED)
set(TINYEXR_LIBRARIES unofficial::tinyexr::tinyexr)
