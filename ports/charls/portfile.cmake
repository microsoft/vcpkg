vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO team-charls/charls
    REF "${VERSION}"
    SHA512 56261e06c080f5ed59ede65cc1159a1796595cad5906c355e1ccc1fb23eb26ff585823fd9bbd0845107db34058df91a660ca18866ddcf6129f8f15737eb25e26
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCHARLS_BUILD_TESTS=OFF
        -DCHARLS_BUILD_SAMPLES=OFF
        -DCHARLS_BUILD_FUZZ_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/charls)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
