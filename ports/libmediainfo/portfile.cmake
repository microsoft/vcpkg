string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" MEDIAINFO_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF "v${MEDIAINFO_VERSION}"
    SHA512 b6a7482d7e7af7ceaf20dc1bdffeac2cf35ceea6f6a1311a8df4658940202cf190a599ba03a1e8d5dad2bd623263b55edd3b20ee0fce78ee1c4f938a014af3b4
    HEAD_REF master
    PATCHES
        dependencies.diff
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
    OPTIONS
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=1
        -DCMAKE_REQUIRE_FIND_PACKAGE_TinyXML=1
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mediainfolib)
vcpkg_fixup_pkgconfig()
if(NOT VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmediainfo.pc" " -lmediainfo" " -lmediainfod")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
