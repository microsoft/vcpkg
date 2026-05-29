#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/wagyu
    REF 0.5.0
    SHA512 d2ef6c056b25e60677da4f53154790558ddb43c56aa117a4d5108f8c7686cceff9e5d54d71138e2eb504f053315d28f7cb8190ff45833c5606d511b685acf40d
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
