#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/polylabel
    REF "v${VERSION}"
    SHA512 e739b0f9c293fd1fd50de56be0804b638ad4ca5ca2c6ee6272907cffc99e133f183f62dd75ca415983ebf9a03da07910b2fa5e8d18b606a6faf7b14baa930622
    HEAD_REF master
)

# Copy header files
file(COPY "${SOURCE_PATH}/include/mapbox/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox" FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
