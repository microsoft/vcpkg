# FluxCap vcpkg portfile. REF/SHA512 pin the release tarball; update both
# together when a new tag is cut (the expected SHA512 is printed on mismatch).

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sxyyds/fluxcap
    REF "v0.1.1"
    SHA512 f34537bb00665a3962dc6ca58a43d1d8f841a68a2437c104a32b5d08b9a81bf322347eabe16abece020b601378bb1077b42258480c82d32acc47592aa80efb64
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
