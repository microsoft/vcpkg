vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF v21.03
    SHA512 1317b27dc3ac1ad224ef9b7ca7c08a8f55983ac6984b5e8daf6309fa33094fbad8a0a5fbe0cff086b7a5c9233b3e24e26995b037d16adf83f63877f2c753f811
    HEAD_REF master
    PATCHES vcpkg_support_in_cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
    OPTIONS
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/share/mediainfolib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/mediainfolib" "${CURRENT_PACKAGES_DIR}/share/MediaInfoLib")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/mediainfolib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/mediainfolib" "${CURRENT_PACKAGES_DIR}/debug/share/MediaInfoLib")
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME MediaInfoLib CONFIG_PATH share/MediaInfoLib)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
