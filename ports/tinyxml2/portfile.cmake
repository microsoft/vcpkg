vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 8.0.0
    SHA512 bcbb065c2af34ea681ec556377fd22e720b6f5d4caa73f432b1e34e08603a96f2233763f0ec5ae86b9ee71ddbe3062f58d3794cd3a162ce6903435530de0bba6
    HEAD_REF master
    PATCHES
        fix-symbol-exports.patch
        fix-debug-postfix.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/tinyxml2)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
