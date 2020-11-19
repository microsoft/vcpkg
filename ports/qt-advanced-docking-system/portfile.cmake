vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 44dc76bd19853dcb18d37d5be231af526c8f709e #v3.6.3
    SHA512 c28aeb7f229c5ea637913ca122c475f235320085bc4a5df3aa4ef493e0ac42d167f21cd893eaac163382916a6f108b5d0e2bc8dda99bebb27c028f98b7e730ba
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        config_changes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.6.3
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/gnu-lgpl-v2.1.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/qtadvanceddocking TARGET_PATH share/qtadvanceddocking)
