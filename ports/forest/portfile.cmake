# Ηeader-only library

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/forest-4.5.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/xorz57/forest/archive/4.5.0.zip"
    FILENAME "forest-4.5.0.zip"
    SHA512 ae256ad38802d0827cfcd45ffae35ddb95cf74e38cf3e5d806f6e2215f701abfb8159f82e2bb6362788fe96a9f9008429d366e7abbc7980b29b3528052cfe43e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
