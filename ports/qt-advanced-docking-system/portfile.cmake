include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 3ffbbfb6d01ff211d8349027221a19b1419296b5
    SHA512 b705d6a125d4e16805e2cc8dda11f157066dc3039decfb058e37e5c9307bdaaa229e448f1d7fe6de0086bd9a2abeac73a64dac93b28bd45bba5e093240e54193
    HEAD_REF master
    PATCHES
        config_changes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/qt-advanced-docking-system RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
