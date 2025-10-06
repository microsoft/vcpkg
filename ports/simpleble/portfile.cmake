vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 059df611a8a529d6ad177e13f3a639a76b9dda8c72395bf660c63239c519096761e123459b814bbfac2e3e3407119477373453891c88daa4532e56f2c77da223
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
