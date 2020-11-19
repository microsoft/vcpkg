# header-only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/variant
    REF a2a4858345423a760eca300ec42acad1ad123aa3 # v1.2.0
    SHA512 6d1ad2f37e137c42592dbd618a3871008d4f83b3cb0d6f05a9c469a6a987ed3fc7f0416ae341646d73e69426903a5a4f64b9f41ae739fd940bbd304dfcae289e
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include/mapbox/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/mapbox FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapbox-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mapbox-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/mapbox-variant/copyright)
