# header-only
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cbeck88/strict-variant
    REF 6378755e3c612cd870c2720232db1e5423dbbe73
    SHA512 45432caab51d42b86839f5ed194e79630ee5cbedd6e41eaadc10d28788ceb8c4629c0432ce888a5729266585e03cf4e6206c8ec66d1b1bc3d7d60220b3909f1d
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/strict-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/strict-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/strict-variant/copyright)
