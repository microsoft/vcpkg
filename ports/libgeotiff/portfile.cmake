include(vcpkg_common_functions)

set(LIBGEOTIFF_VERSION 1.4.2)
set(LIBGEOTIFF_HASH 059c6e05eb0c47f17b102c7217a2e1636e76d622c4d1bdcf0bd89fb3505f3130bffa881e21c73cfd2ca0d6863b81322f85784658ba3539b53b63c3a8f38d1deb)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz"
    FILENAME "libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz"
    SHA512 ${LIBGEOTIFF_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBGEOTIFF_VERSION}
    PATCHES
        0001-Updates-to-CMake-configuration-to-align-with-other-C.patch
        0002-Fix-directory-output.patch
        0004-Fix-libxtiff-installation.patch
        0005-Control-shared-library-build-with-option.patch
        0006-Fix-utility-link-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TIFF=ON
        -DWITH_PROJ4=ON
        -DWITH_ZLIB=ON
        -DWITH_JPEG=ON
    OPTIONS_RELEASE -DWITH_UTILITIES=ON
    OPTIONS_DEBUG   -DWITH_UTILITIES=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libgeotiff RENAME copyright)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*)
else()
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
endif()

file(INSTALL ${GEOTIFF_UTILS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/libgeotiff/)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/libgeotiff)

file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(EXES)
    file(REMOVE ${EXES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()
