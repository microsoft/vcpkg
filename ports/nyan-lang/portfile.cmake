# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "nyan currently only supports Linux and Mac platforms" ON_TARGET "Windows")

set(VERSION 0.1)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SFTtech/nyan
    REF v0.3
    SHA512 53411795142aa2dfd197d4e550a9de4f2e68519426a228d7e9fe162e8f113886ae5febbceef8daa643c60a9089ede4b5c8dda9c136617357b58279cc732efba6
    HEAD_REF master
)

vcpkg_find_acquire_program(FLEX)

get_filename_component(FLEX_PATH ${FLEX} DIRECTORY CACHE)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFLEX_ROOT=${FLEX_PATH}
        -DCMAKE_POLICY_DEFAULT_CMP0074=NEW
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_copy_tools(TOOL_NAMES nyancat AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/legal/GPLv3 ${SOURCE_PATH}/legal/LGPLv3 ${SOURCE_PATH}/copying.md)
