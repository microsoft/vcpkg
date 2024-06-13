string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" MEDIAINFO_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF "v${MEDIAINFO_VERSION}"
    SHA512 6d0f2d7d37aa4fd01fb3e5d82e5b8b6572238b916d2275689f02cc72ed7af54353a324cdff5c2a1d240e586ee33ae8ff8650193dcd353d1fd01bd75234a49c6d
    HEAD_REF master
    PATCHES
        msvc-arm.diff
        dependencies.diff
        no-windows-namespace.diff
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
