# header-only
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyexr-d16ea6347ae78bcee984fb57cab1f023aeda4fb0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/syoyo/tinyexr/archive/d16ea6347ae78bcee984fb57cab1f023aeda4fb0.tar.gz"
    FILENAME "tinyexr-v0.9.5-d16ea6.tar.gz"
    SHA512 63399688d7894f9ac4b893b2142202b36108b5029b11c40c3f9ad0f0135625fb0c8e0d54cec88d92c016774648dc829a946d9575c5f19afea56542c00759546e
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${SOURCE_PATH}/tinyexr.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexr)
