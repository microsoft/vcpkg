# header-only
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyexr-d16ea6347ae78bcee984fb57cab1f023aeda4fb0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/syoyo/tinyexr/archive/d16ea6347ae78bcee984fb57cab1f023aeda4fb0.tar.gz"
    FILENAME "tinyexr-v0.9.5-d16ea6.tar.gz"
    SHA512 189ab04f6c5fb50c20ac0515a83ee16cba4b0f1bca004db2926281077868d1384e0c54f81768a54b76286a17c1b0c45a0b82acaf22b7ee843dc87c654b09e950
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${SOURCE_PATH}/tinyexr.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexr)
