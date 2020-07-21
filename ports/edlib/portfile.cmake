vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Martinsos/edlib
    REF v1.2.6
    SHA512 75b470c1403113e5f0895b3c1bb4163e65c6e04ccf41a75297a5b4cc915a567567ebcc79f3b9ea74b5e7188adfab2eceda5ac75e2d861aef8b3fefc6d4f39200
    HEAD_REF master
    PATCHES
        fix-cmake-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/edlib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
