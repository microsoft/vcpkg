vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spnda/fastgltf
    REF "v${VERSION}"
    SHA512 a1456790a44b8d172e19425835d28e5a48994b8494b3f4b197dbab77c049816eead73cfc978e3ef6d41084799f4875b15ef88020357404d278f35189969d69d2
    HEAD_REF main
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
