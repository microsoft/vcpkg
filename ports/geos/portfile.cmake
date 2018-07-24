# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/geos-3.6.2)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/geos/geos-3.6.2.tar.bz2"
    FILENAME "geos-3.6.2.tar.bz2"
    SHA512 515d8700b8a28282678e481faee355e3a43d7b70160472a63335b8d7225d9ba10437be782378f18f31a15288118126d411a2d862f01ce35d27c96f6bc0a73016
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(

SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/geos_c-static-support.patch
)

# NOTE: GEOS provides CMake as optional build configuration, it might not be actively
# maintained, so CMake build issues may happen between releases.

# Pull modules referred in the main CMakeLists.txt but missing from the released package.
# TODO: GEOS 3.6.3 or later will include the missing script in release package.
file(DOWNLOAD http://svn.osgeo.org/geos/branches/3.6/cmake/modules/GenerateSourceGroups.cmake
    ${SOURCE_PATH}/cmake/modules/GenerateSourceGroups.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
    -DCMAKE_DEBUG_POSTFIX=d
    -DGEOS_ENABLE_TESTS=False
)
vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/geos)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/geos/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libgeos.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libgeosd.lib)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/geos.lib ${CURRENT_PACKAGES_DIR}/debug/lib/geosd.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/geos_c.lib ${CURRENT_PACKAGES_DIR}/debug/lib/geos_cd.lib)

endif()

vcpkg_copy_pdbs()
