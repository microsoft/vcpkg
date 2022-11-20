#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/polylabel
    REF v1.0.4
    SHA512 c337577545e072dbc43b5fc822e7a4fc9585051e24f6af76a3525faee7ab5c332915c43401629ad2e8f1f142f9e920f65347609607aec9394fd6bbc5d4936564
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
