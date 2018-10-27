include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF 0.2.1
    SHA512 8b91738183a6d81c2c0381b4279cff9d8f811dac643ce5e08aa869058f5653ad8a2d9d8f9e563b26ad75b617b80b10ccb32753984a50ed684529a90bdd248bff
    HEAD_REF master
    PATCHES 0001-fix-version.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include/config.h)

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/libyaml/copyright COPYONLY)
