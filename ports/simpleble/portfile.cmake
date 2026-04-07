vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 c53c435c53f4829bfe1f1db94a94693958a23174689b798ae32d9518725efbb3173540e150c5a630ee53752d3e49f80f9e412c1c21e9f7a326369592d47cab46
    PATCHES
        use-std-localtime.patch
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
