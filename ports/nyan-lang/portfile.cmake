vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VERSION 0.3)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SFTtech/nyan
    REF "v${VERSION}"
    SHA512 53411795142aa2dfd197d4e550a9de4f2e68519426a228d7e9fe162e8f113886ae5febbceef8daa643c60a9089ede4b5c8dda9c136617357b58279cc732efba6
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
