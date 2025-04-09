set(LIB_FILENAME libvhdi-alpha-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libvhdi/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 5eddbb2ea5800f4427a9763b904b74d1b4a876844f0fb00a8e758c73424171ff7b52a821b1618ea575e9553e6ab357ce80884fab8503dcfc36343a32f80ecd02
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES macos_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libvhdi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/COPYING"
)

vcpkg_copy_pdbs()
