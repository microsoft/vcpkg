vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SFTtech/nyan
    REF "v${VERSION}"
    SHA512 2549e69f88f42b00bc9618c24031d5ff9588eb9249c973bc5eedb51634be619ad0e7118f1fb7f3abb31553763c0c95ce222e0f95f8e628e7b453b5c862b6bb7c
    HEAD_REF master
)

vcpkg_find_acquire_program(FLEX)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DFLEX_EXECUTABLE=${FLEX}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_copy_tools(TOOL_NAMES nyancat AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/copying.md"
        "${SOURCE_PATH}/legal/LGPLv3"
        "${SOURCE_PATH}/legal/GPLv3"
)
