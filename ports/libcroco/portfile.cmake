vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/libcroco/0.6/libcroco-0.6.13.tar.xz"
    FILENAME "libcroco-0.6.13.tar.xz"
    SHA512 038a3ac9d160a8cf86a8a88c34367e154ef26ede289c93349332b7bc449a5199b51ea3611cebf3a2416ae23b9e45ecf8f9c6b24ea6d16a5519b796d3c7e272d4
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
configure_file("${SOURCE_PATH}/config.h.win32" "${SOURCE_PATH}/src/config.h" COPYONLY)
file(READ "${SOURCE_PATH}/src/libcroco.symbols" SYMBOLS)
string(REGEX REPLACE ";[^\n]*\n" "" DEF "EXPORTS\n${SYMBOLS}")
file(WRITE "${SOURCE_PATH}/src/libcroco.def" "${DEF}")

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CURRENT_PORT_DIR}/unofficial-libcroco-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libcroco")
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
