include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 6cc7d7983201596a3f579adbe09417fe8c73c409
    SHA512 fc508ffb69a265ac52a9be72854140717e7c61925c7275e44fd2f76d0df03637b8d7fd61b7ce86e03fa1e9bf0a0e4a9c2ed9477b9d758a3b0e4760839288e431
    HEAD_REF master
    PATCHES
        config_changes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt-advanced-docking-system RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)