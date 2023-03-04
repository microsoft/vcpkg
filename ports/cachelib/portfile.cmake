vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/CacheLib
    REF "v${VERSION}"
    SHA512 53f2eb4de0d1c5d4184d7e1d8ceb958625d9426eebaf434227179c9b2a6ed3a3bf063758f86c2e517ca910556230a764bfd54890dc718c2f45aec1d5a806788c
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cachelib"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DCMAKE_INSTALL_DIR=share/cachelib
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cachelib PACKAGE_NAME cachelib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
