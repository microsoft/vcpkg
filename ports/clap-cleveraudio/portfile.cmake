vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO free-audio/clap
    REF "${VERSION}"
    SHA512 22c0de322ed48fea0011756864e4a0e5df838dc5554f0d8671dc9cbe3d888b0116ecb55b7ceee55a1735a65163d25745915e0164ab1624d1213ab72dd9ab7cb9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/clap")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
