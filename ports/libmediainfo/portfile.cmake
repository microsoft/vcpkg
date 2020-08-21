vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF v20.08
    SHA512 271742af2b2407c04a0555d851fc9ef5590326f4101413ef2092d0a0b99e8367d01bb6442464d171b582b00bb2f45edb9bc9867e74a8d14daba99e2416bc08f3
    HEAD_REF master
    PATCHES vcpkg_support_in_cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Project/CMake
    PREFER_NINJA
    OPTIONS
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/mediainfolib TARGET_PATH share/mediainfolib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
