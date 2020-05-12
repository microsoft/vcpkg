vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 661d0c4356ab61d155b53718aa1bf6bab86dad13
    SHA512 3504d91b63cc68abbc56e935f22dda2e5b667400501b547a159e3e43d5862c2cff5739423606732361b331b00596202a19a67c3273948cccfbdb8593970cb840
    HEAD_REF master
    PATCHES
        config_changes.patch
        skip_license_install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/gnu-lgpl-v2.1.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
