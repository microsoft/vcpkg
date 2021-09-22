vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF 8f5d381e867369ffcef3faac7932e43ada9a72dd #v21.09
    SHA512 0d86f6a59bd86185538b6f0a413f1d0e2f4d5ffa6457b6f0b9ee3e5af4a116861344aec5f830040bb9216d6c581a98fd349e5e6a33275e8c2bfc2da2042739cc
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)