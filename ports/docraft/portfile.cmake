vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/Docraft
    REF ${VERSION}
    SHA512 ad308dae0d9b3ddc4b696a3369d0a7547551540dda99f72db641557b92ce2ec537406e2409b7e80ef3f0dff7ed5945a30e46218185f4894c92128fc98784ff82
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
