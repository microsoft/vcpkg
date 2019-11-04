include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(CAIROMM_VERSION 1.15.3)
set(CAIROMM_HASH a2c28786dbd167179561d8f580eeb11d10634a36dfdb1adeefc0279acf83ee906f01f264cb924845fc4ab98da1afac71e1ead742f283c1a32368ca9af28e464a)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.gz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.gz"
    SHA512 ${CAIROMM_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-fix-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH}/build)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
