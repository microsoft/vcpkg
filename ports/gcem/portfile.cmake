vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kthohr/gcem
    REF a20b0fc0206ff7d99a96fe4afdfe8205b01c8220 # v1.13.1
    SHA512 baede14856ddcf8f132c7a16b19d4d646a1fc2d5e3a536a46694a8d7c656ce4ffb2fd61f50a1df78ce7ed31528828152b4e881fe10bcead553985b6103018804
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/gcem)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
