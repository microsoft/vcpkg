
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF 58a81c36caad469aed86441cc91080f23b496ffb
    SHA512 ba0cec26d8487f793b0deee4e269830618506be291175dd968a83384e9f892c1639950ec2bdaefd6e210c091189a774962ee5b42bc143ffceec21dcc55ba4abe
    HEAD_REF master
    PATCHES
        fixtargets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
