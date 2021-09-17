#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/geometry.hpp
    REF v2.0.3
    SHA512 76c10578e1fba44430786fb5e043dbc063aa251f62396701a509f7fa1e2e5c351fa0fe041d16be84bda9816ec5df3342cd9890da6fe99d78d6fb26e0a3b2485b
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
