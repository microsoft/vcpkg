#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/geojson-vt-cpp
    REF v6.6.5
    SHA512 4989522c19f35ba13096958ad1041ec09745020955fad99ee02116393885a9d0a835911a42167a76d5efb2a5dd167077bcd451c9a77444f2eaa26893a1bff062
    HEAD_REF master
)

# Copy header files
file(COPY "${SOURCE_PATH}/include/mapbox/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox" FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
