#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/geojson-vt-cpp
    REF v6.6.4
    SHA512 8a78159112be3e6a1a477fbb92e7bd9645b0b174ab6db7ef72557e154d53c3a9fb818d62b6f0d0a5b8b8a9839132c523fb44efa038388d4cd2b46c5bea60d2da
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
