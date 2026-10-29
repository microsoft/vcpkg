vcpkg_download_distfile(
    ARCHIVE URLS "https://codeberg.org/tenacityteam/libid3tag/archive/${VERSION}.tar.gz"
    FILENAME "libid3tag-${VERSION}.tar.gz"
    SHA512 7ea09cc9a2047799d3f8a0dceebc9822ea1625f045c637a65dfa85364b17556b5dccb8b6cc9a8991e45f2b8d35d2b4f0fd084144afb40738d99bc0a60479223c
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-install-include-dir.patch
        fix-pkgconfig-zlib.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DGPERF=${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME id3tag CONFIG_PATH lib/cmake/id3tag)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
