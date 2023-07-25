# port update requires rust/cargo

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/librsvg/2.40/librsvg-2.40.20.tar.xz"
    FILENAME "librsvg-2.40.20.tar.xz"
    SHA512 cdd8224deb4c3786e29f48ed02c32ed9dff5cb15aba574a5ef845801ad3669cfcc3eedb9d359c22213dc7a29de24c363248825adad5877c40abf73b3688ff12f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/config.h.linux" "${SOURCE_PATH}/config.h.linux" COPYONLY)

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE 
    OPTIONS
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-librsvg CONFIG_PATH share/unofficial-librsvg)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
