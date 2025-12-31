vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 076490b660629cc947446d11c42a0bb7811b5a3fad6b41eb3e9b9dfb5108b436d9688e36fb1b716fde0c07f8a2c004962bf1657c9a395891095a9343031d73fb
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
