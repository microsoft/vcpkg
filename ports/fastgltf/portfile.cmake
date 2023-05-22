vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 c8dd1deabcb23d3ecc1a85fcd874fe5f092f759cb3345c3bc348ae84626ccae378b3a4a5d0c026fa64d2c9717ca1c5d57bac052a62a2b7f6bbd671e8a005db88
    HEAD_REF main
    PATCHES find_package.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DFASTGLTF_DOWNLOAD_SIMDJSON=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
