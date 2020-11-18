#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/geometry.hpp
    REF c83a2ab18a225254f128b6f5115aa39d04f2de21
    SHA512  81c93a4efb517866888aee86ccb61896f4465f862d5404b0e45e35632a3bf6fb2d5c46935bbe56ff03079861ea503bd13d9d4003d5aae50cad5d1b2187834661
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")


# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

