include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zziplib-0.13.62)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/zziplib/files/zziplib13/0.13.62/zziplib-0.13.62.tar.bz2/download"
    FILENAME "zziplib-0.13.62.tar.bz2"
    SHA512 fd3b9e9015ba7603bdebd8f6a2ac6d11003705bfab22f3a0025f75455042664aea69440845b59e6f389417dff5ac777f49541d8cbacb2a220e67d20bb6973e25
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/zziplib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zziplib/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/zziplib/copyright)
