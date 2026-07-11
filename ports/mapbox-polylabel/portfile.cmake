#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/polylabel
    REF "v${VERSION}"
    SHA512 cd9c50838f2acf2789ea49299725274de0fa90e24d440626779c8c21e20175903fa0cb40af0de73c7c1d9d273fbde15a795210216ec920031b31c700c51cc285
    HEAD_REF master
)

# Copy header files
file(COPY "${SOURCE_PATH}/include/mapbox/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox" FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
