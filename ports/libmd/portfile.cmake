vcpkg_download_distfile(
        LIBMD_ARCHIVE
        URLS "https://archive.hadrons.org/software/libmd/libmd-1.1.0.tar.xz"
        FILENAME "libmd-1.1.0.tar.xz"
        SHA512 5d0da3337038e474fae7377bbc646d17214e72dc848a7aadc157f49333ce7b5ac1456e45d13674bd410ea08477c6115fc4282fed6c8e6a0bf63537a418c0df96
)
vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${LIBMD_ARCHIVE}"
)

vcpkg_list(SET MAKE_OPTIONS)
vcpkg_list(SET LIBMD_LINK_LIBRARIES)
vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${MAKE_OPTIONS}
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
