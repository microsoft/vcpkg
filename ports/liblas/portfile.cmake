vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VERSION 1.8.1)
                                              
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/liblas/libLAS-${VERSION}.tar.bz2"
    FILENAME "libLAS-${VERSION}-src.tar.bz2"
    SHA512 1cb39c557af0006c54f1100d0d409977fcc1886abd155c1b144d806c47f8675a9f2125d3a9aca16bae65d2aabba84d5e5e322b42085e7db312f3d53f92342acf  
    HEAD_REF master
)

vcpkg_extract_source_archive_ex(
    ARCHIVE "${ARCHIVE}"
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-boost-headers.patch
        misc-fixes.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_OSGEO4W=OFF
        -DWITH_TESTS=OFF
        -DWITH_UTILITIES=OFF
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libLAS)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
