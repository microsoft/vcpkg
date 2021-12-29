set(VERSION 1.8.1)
                                              
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/liblas/libLAS-${VERSION}.tar.bz2"
    FILENAME "libLAS-${VERSION}-src.tar.bz2"
    SHA512 1cb39c557af0006c54f1100d0d409977fcc1886abd155c1b144d806c47f8675a9f2125d3a9aca16bae65d2aabba84d5e5e322b42085e7db312f3d53f92342acf  
    HEAD_REF master
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        fix-boost-headers.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindPROJ4.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindGeoTIFF.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_OSGEO4W=OFF # Disable osgeo4w
        -DWITH_TESTS=OFF
        -DWITH_UTILITIES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=${CMAKE_DISABLE_FIND_PACKAGE_ZLIB}
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=${CMAKE_DISABLE_FIND_PACKAGE_JPEG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/share/cmake/libLAS/liblas-depends.cmake)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libLAS)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
