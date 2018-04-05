# Ηeader-only library

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/forest-7.0.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/xorz57/forest/archive/7.0.1.zip"
    FILENAME "forest-7.0.1.zip"
    SHA512 c3e59f79fba57abc4583a7feb4645e2e383ca42fdbc014abf002e88ca5a720d443039329cdc497ffe4c72323c2843f614d190f2fd7c1c9083d57972791161525
)
vcpkg_extract_source_archive(${ARCHIVE})

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
