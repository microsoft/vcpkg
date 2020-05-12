set(GEOS_VERSION 3.6.4)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 860513d86ee1294814ff3b3240373ee3a9ce88be9508b45f61ccc982bb698d0a1916e9458c37853ce8d69a977db6f12483745859f86617d704a688cfeb83b1e9
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GEOS_VERSION}
    PATCHES geos_c-static-support.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DGEOS_ENABLE_TESTS=False
)
vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/geos-config)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/geos)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/geos-config ${CURRENT_PACKAGES_DIR}/share/geos/geos-config)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/geos-config)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright COPYONLY)

vcpkg_copy_pdbs()
