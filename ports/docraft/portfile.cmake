vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/Docraft
    REF ${VERSION}
    SHA512 78553340b7deabdc0497bdad65e681f86df3ca457358254e5bf4199e1e8e5dee5a500397ae846d9c415417f29d4eaa3730dbb742e19be9e9de758a20b9ce9e84
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
