vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/Docraft
    REF ${VERSION}
    SHA512 fee1f78fb013b592faf3107e6bd77485f14755d0a1add6b3f906b896f743c693bd900ce26f6d347a577e00f507d541917657ab6ccae93a2de800ab68a1adbd93
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
