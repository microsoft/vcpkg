# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "nyan currently only supports Linux and Mac platforms" ON_TARGET "Windows")

set(VERSION 0.1)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SFTtech/nyan
    REF 97ab90a6c878318f613ae0e9a4d60428d589f451
    SHA512 d2ade03201643198539b19e94cb8ba775fb69c0199a08e7291bd31f616453e8dfd7bfa48302683423e4e1270a412c3da4aa1fe3a5f9c39b8f806dcf7dfe1666a
    HEAD_REF master
)

vcpkg_find_acquire_program(FLEX)

get_filename_component(FLEX_PATH ${FLEX} DIRECTORY CACHE)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFLEX_ROOT=${FLEX_PATH}
        -DCMAKE_POLICY_DEFAULT_CMP0074=NEW
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file(${SOURCE_PATH}/legal/LGPLv3 ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
