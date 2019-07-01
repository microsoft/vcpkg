# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/variant
    REF 0f734f01e685a298e3756d30044a4164786c58c5
    SHA512 36b842ffbaa7d466c26b4783d68dff17b0079927aca876bd021f439591a4ee5f184c71a60ca59857c35675b2e27cf650bedea7a3cdf9c3fc959c3c0ec3b135eb
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapbox-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mapbox-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/mapbox-variant/copyright)
