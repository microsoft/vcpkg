include(vcpkg_common_functions)

set(LIBGEOTIFF_VERSION 1.4.2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz"
    FILENAME "libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz"
    SHA512 059c6e05eb0c47f17b102c7217a2e1636e76d622c4d1bdcf0bd89fb3505f3130bffa881e21c73cfd2ca0d6863b81322f85784658ba3539b53b63c3a8f38d1deb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBGEOTIFF_VERSION}
    PATCHES
        cmakelists.patch
        geotiff-config.patch
)

# Delete FindPROJ4.cmake
file(REMOVE ${SOURCE_PATH}/cmake/FindPROJ4.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TIFF=ON
        -DWITH_PROJ4=ON
        -DWITH_ZLIB=ON
        -DWITH_JPEG=ON
        -DWITH_UTILITIES=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB GEOTIFF_UTILS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${GEOTIFF_UTILS_DEBUG})
endif()

file(COPY ${GEOTIFF_UTILS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/libgeotiff)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/libgeotiff)
file(REMOVE ${GEOTIFF_UTILS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/GeoTIFF)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/libgeotiff/geotiff-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/libgeotiff/geotiff-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/libgeotiff/geotiff-depends-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/libgeotiff/geotiff-depends-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/libgeotiff/geotiff-depends.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgeotiff RENAME copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/doc ${CURRENT_PACKAGES_DIR}/share/libgeotiff/doc)
