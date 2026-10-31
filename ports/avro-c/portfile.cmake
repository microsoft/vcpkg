vcpkg_buildpath_length_warning(37)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/avro/avro-${VERSION}/avro-src-${VERSION}.tar.gz"
    FILENAME "avro-src-${VERSION}.tar.gz"
    SHA512 a31ad410d75c0e7f58fc9d9b7e7989dae12f328524806f6d64fdae22ddb9112fe2adc5fb74ee83df2135b87bd6618e8765a823220b2a0a162d1684192b9926da
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        avro.patch          # Private vcpkg build fixes
        bswap.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# the files are broken and there is no way to fix it because the snappy dependency has no pkgconfig file
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_copy_tools(TOOL_NAMES avroappend avrocat AUTO_CLEAN)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES avropipe avromod AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/lang/c/LICENSE"
        "${SOURCE_PATH}/lang/c/NOTICE"
)
