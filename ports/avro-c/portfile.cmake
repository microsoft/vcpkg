vcpkg_buildpath_length_warning(37)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF "release-${VERSION}"
    SHA512 4e7fd7ebb41f6149a499d0d38babd99d07f936143b47a60f7c568a589fb0e6369301c7230bde518b554eaeaa9ded1ed1fae2661cbd5ebc49fb5f22d97c066f05
    HEAD_REF master
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lang/c/LICENSE")
