# FluxCap vcpkg portfile. REF/SHA512 pin the release tarball; update both
# together when a new tag is cut (the expected SHA512 is printed on mismatch).

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sxyyds/fluxcap
    REF "v0.1.1"
    SHA512 86b38f6b23b29bc2847abd5f2783564887dfda3ad3a4151282fde764b47dc807af32b6707f870c1b2bc112f7db5282ec34de5dac36d2054bb23b7fed3727d505
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLUXCAP_BUILD_EXAMPLES=OFF
        -DFLUXCAP_BUILD_BENCHMARKS=OFF
        -DFLUXCAP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/FluxCap
    PACKAGE_NAME FluxCap
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
