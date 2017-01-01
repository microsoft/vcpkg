# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/3.5)
#downloading 3.5 from their SVN repo and not the release tarball
#because the 3.5 release did not build on windows, and fixes were backported
#without generating a new release tarball (I don't think very many GIS people use win)
vcpkg_download_distfile(ARCHIVE
    URLS "https://trac.osgeo.org/geos/browser/branches/3.5?rev=4261&format=zip"
    FILENAME "geos-3.5.0.zip"
    SHA512 3b91e8992f60b99a3f01069d955b71bce425ae5e5c599252fa26a337494e1a5a8ea796be124766d054710d6c03806f56dc1c63539b4660e2bb894d7ef779d4b9
)
vcpkg_extract_source_archive(${ARCHIVE})

#we need to do this because GEOS deploy process is totally broken for cmake
#file(DOWNLOAD http://svn.osgeo.org/geos/tags/3.5.0/cmake/modules/GenerateSourceGroups.cmake
#    ${SOURCE_PATH}/cmake/modules/GenerateSourceGroups.cmake)
file(WRITE ${SOURCE_PATH}/geos_svn_revision.h "#define GEOS_SVN_REVISION 4261")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DGEOS_ENABLE_TESTS=False
            -DBUILD_TESTING=False
)

vcpkg_build_cmake()
vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/geos)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/geos/COPYING ${CURRENT_PACKAGES_DIR}/share/geos/copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libgeos.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libgeos.lib)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/geos.lib ${CURRENT_PACKAGES_DIR}/debug/lib/geos.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/geos_c.lib ${CURRENT_PACKAGES_DIR}/debug/lib/geos_c.lib)

endif()

vcpkg_copy_pdbs()