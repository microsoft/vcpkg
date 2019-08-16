include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(CAIROMM_VERSION 1.15.3)
set(CAIROMM_HASH a2c28786dbd167179561d8f580eeb11d10634a36dfdb1adeefc0279acf83ee906f01f264cb924845fc4ab98da1afac71e1ead742f283c1a32368ca9af28e464a)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cairomm-${CAIROMM_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.gz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.gz"
    SHA512 ${CAIROMM_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH}/build)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-build.patch")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/cairomm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cairomm/COPYING ${CURRENT_PACKAGES_DIR}/share/cairomm/copyright)
