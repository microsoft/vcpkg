include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 3ffbbfb6d01ff211d8349027221a19b1419296b5
    SHA512 0f71a9015f6f500ef5749d6ea3e1d5311d7e892fe5d21fc59f65736484c95d37eb7a03354ab34f8c3801813fa6bcbdcc1746cdbdc262b3870f5b323dc3acca5d
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
