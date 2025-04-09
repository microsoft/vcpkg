vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-quantum-safe/liboqs
    REF ${VERSION}
    SHA512 93260f15c02108157fa595e252685c49c5fb6433d04b989c381da4e27169577f3011d9174b2ec0c110fff15d2d3c640a9833bf28aa53949e8f33c0e674b6e781
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOQS_BUILD_ONLY_LIB=ON
        -DOQS_PERMIT_UNSUPPORTED_ARCHITECTURE=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
