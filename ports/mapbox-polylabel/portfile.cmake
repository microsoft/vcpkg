#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/polylabel
    REF 51f09d04c21e7b7faf94e2300ca1fe6e1f12fa7f
    SHA512 75ddb479d4aa6768f161cc4d0f94121097c0f97840e9d677adec59b7360f8245bca54770cc894c7d10171c1cfea6e9a1ab73a7b45dff383791baa60bcf2226b9
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")


# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

