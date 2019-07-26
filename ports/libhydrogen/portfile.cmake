include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libhydrogen
    REF 01c3ec04079f93b0f7b798ab7616ac483efea132
    SHA512 ba7e1fcf6e2d93c4234bb175b5e1db2369cefd4e360fe50592c1fbb3a3689cde9c6a120e182c4f767e20b1ee3fd4cdc6d66afc52b18e3968b7c6f76d1f97bd8e
    HEAD_REF master
    PATCHES
        disable-wx-flag.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/hydrogen TARGET_PATH share/hydrogen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME hydrogen)
