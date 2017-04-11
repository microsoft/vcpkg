include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    message(FATAL_ERROR "libP7 does not support ARM")
endif()

set(LIBP7_VERSION 4.1)
set(LIBP7_HASH 6259416378f1fe60ad6097faf9facd2de1a3ea13e8015a5727d6a179caa88a7f6707b47273afceebc16b39883da4768f29feac199f7d6c354b744b643c2044ab)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libP7_v${LIBP7_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://baical.net/files/libP7_v${LIBP7_VERSION}.zip"
    FILENAME "libP7_v${LIBP7_VERSION}.zip"
    SHA512 ${LIBP7_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libp7-baical/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libp7-baical/License.txt ${CURRENT_PACKAGES_DIR}/share/libp7-baical/copyright)