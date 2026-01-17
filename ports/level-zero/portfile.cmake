vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 d79701d2608353b4d3791be5ed67e9055fbd7cd7ba8ac76b50b0178bc455fc6ce7ec97d30a144cf81d17ca9ed3e72dd9a7d6e77521084228807b1bec9d027b2f
    HEAD_REF master
    PATCHES spdlog_include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSTEM_SPDLOG=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

