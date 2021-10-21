vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF d5fb067e1539aa7a74c491e8262c81214f9c8bcb #v21.03
    SHA512 6d49c8187dca264b4d9fb1f93a82cb65435e81a2540cfb84f885d53737560f7e8e60c8209e7d184cb191f298495db90ffb3185481e3ed44bf5a1f5131f671d89
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