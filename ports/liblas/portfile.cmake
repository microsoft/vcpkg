include(vcpkg_common_functions)

set(VERSION 1.8.1)
                                              
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libLAS-${VERSION})
vcpkg_download_distfile(ARCHIVE
	URLS "http://download.osgeo.org/liblas/libLAS-${VERSION}.tar.bz2"
	FILENAME "libLAS-${VERSION}-src.tar.bz2"
    SHA512 1cb39c557af0006c54f1100d0d409977fcc1886abd155c1b144d806c47f8675a9f2125d3a9aca16bae65d2aabba84d5e5e322b42085e7db312f3d53f92342acf  
	HEAD_REF master
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES fix-BuildError.patch
)


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DBUILD_OSGEO4W=OFF # Disable osgeo4w
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblas RENAME copyright)
