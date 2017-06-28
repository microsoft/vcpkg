include(vcpkg_common_functions)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/apr-util-1.6.0)
vcpkg_download_distfile(ARCHIVE
  URLS "https://archive.apache.org/dist/apr/apr-util-1.6.0-win32-src.zip"
  FILENAME "apr-util-1.6.0-win32-src.zip"
  SHA512 98679ea181d3132020713481703bbefa0c174e0b2a0df65dfdd176e9771935e1f9455c4242bac19dded9414abe2b9d293fcc674ab16f96d8987bcf26346fce3a
)
vcpkg_extract_source_archive(${ARCHIVE})

set(APR_HOME ${VCPKG_ROOT_DIR}/packages/apr_${TARGET_TRIPLET})
set(EXPAT_HOME ${VCPKG_ROOT_DIR}/packages/expat_${TARGET_TRIPLET})
set(EXPAT_LIB ${EXPAT_HOME}/lib/expat.lib)
set(EXPAT_LIB_DEBUG ${EXPAT_HOME}/debug/lib/expat.lib)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(BUILD_SHARED_LIBRARY ON)
else()
  set(BUILD_SHARED_LIBRARY OFF)
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/use-vcpkg-expat.patch"
)


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
  -DAPR_HOME=${APR_HOME}
  -DEXPAT_LIB=${EXPAT_LIB}
  -DEXPAT_HOME=${EXPAT_HOME}
  -DBUILD_SHARED_LIBRARY=${BUILD_SHARED_LIBRARY}
  OPTIONS_DEBUG -DEXPAT_LIB=${EXPAT_LIB_DEBUG} -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/apr-util RENAME copyright)

vcpkg_copy_pdbs()
