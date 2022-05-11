vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(LIB_VERSION 20180714)
set(LIB_FILENAME libpff-experimental-${LIB_VERSION}.tar.gz)

# Release distribution file contains configured sources, while the source code in the repository does not.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libpff/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 7207ba87607ea2fd4609a081c2f4b061344a783e188605e88df99fd473f2a8da1269b065e57b054f4622888d40aa8f2b8272dc4748334ddfe358b28d443d6ad1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIB_VERSION}
)


file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libpff PACKAGE_NAME unofficial-libpff)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
