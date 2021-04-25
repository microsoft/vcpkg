vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO berndporr/iir1
    REF 67591c8eac591c576b9aabe9a2f288296bb263f0 #1.8.0
    SHA512 7bea56bd3a5251656834f43ea55e1a8bff48ed2b5576ea9d7bc058e371457b7a3e8fe26111ec9457d4aa9e397f3267d330c5353aea00810a5cc4d9bec2bdcc72
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH  lib/cmake)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
