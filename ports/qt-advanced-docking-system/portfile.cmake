vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF d5fefaa35fb53e299b7f39b0d8f541954c710d94 #v3.8.2
    SHA512 0 
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        config_changes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.8.2
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME qtadvanceddocking CONFIG_PATH lib/cmake/qtadvanceddocking)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/license")

file(INSTALL "${SOURCE_PATH}/gnu-lgpl-v2.1.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
