vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(LIB_VERSION 20221124)
set(LIB_FILENAME libqcow-alpha-${LIB_VERSION}.tar.gz)

# Release distribution file contains configured sources, while the source code in the repository does not.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libqcow/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 5e48491ec8951473b8791fd6058d35b2d3c00b0206d4ca4fc69b6d42c26ba0a775efe41974989a3965a6a17f4361dd01f874aadef08fe5d80be75d9e6aea6450
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE ${LIB_VERSION}
    PATCHES macos_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libqcow")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
