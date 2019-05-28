include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF d407f6b1cccbf83ee182144f39689babcb220bd6
    SHA512 284182af48b8f7cfa7893e1f830076784e2f9eee9bed5e5aef30ca3e2ab08410c10f19f67e5c10d11e59306685f577adaf08c3698792b8d6a0f53122e7ae1876
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
