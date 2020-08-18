vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF v20.03
    SHA512 c5d3444c8694ca68ee08f97f387cef3aefd9fbb23623b643a6daf9ed7d247521f1291a8a13c9088b31be9a9d594ca772d3125d6eb3d3770bee1f7c50b3b23c07
    HEAD_REF master
    PATCHES vcpkg_support_in_cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Project/CMake
    PREFER_NINJA
    OPTIONS -DBUILD_ZENLIB=0 -DBUILD_ZLIB=0
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/mediainfolib TARGET_PATH share/mediainfolib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
