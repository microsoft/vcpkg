_find_package(${ARGS})

# Extra dependencies for static builds
#
find_package(GIF REQUIRED)
find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(TIFF REQUIRED)

# SAIL::sail-codecs exists when SAIL is compiled with SAIL_COMBINE_CODECS=ON
#
if (TARGET SAIL::sail-codecs)
    set_property(TARGET SAIL::sail-codecs APPEND PROPERTY INTERFACE_LINK_LIBRARIES GIF::GIF JPEG::JPEG PNG::PNG TIFF::TIFF)
endif()
