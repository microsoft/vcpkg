vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF a07397dbdd7f8149b7b235b5b21b88b60e8cfbed
    SHA512 f9bdb668da151dbc2335b9cfd17a130fdefb349e57e9ff3a270e1c0cc8b7ad1bfdf03704cd1e2c1c7c8b34f44684aa2bf649c14666c2c6fd9ea0ddad1e6bc8a3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/simpleble"
    OPTIONS
        -DLIBFMT_VENDORIZE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/simpleble")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
