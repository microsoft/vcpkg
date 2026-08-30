vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/Docraft
    REF ${VERSION}
    SHA512 a324cdf71039e1284a854c9498192ea680cc398a7c7061e7a350892f4e67cd5d1e1c4b6fbf0e6433393dda4029e8226ae2f4b35cffcbf4342992939cf21d1117
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES docraft_tool AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME docraft)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
