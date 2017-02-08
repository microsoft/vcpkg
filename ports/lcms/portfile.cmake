include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lcms2-2.8)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/lcms/files/lcms/2.8/lcms2-2.8.tar.gz/download"
    FILENAME "lcms2-2.8.tar.gz"
    SHA512 a9478885b4892c79314a2ef9ab560e6655ac8f2d17abae0805e8b871138bb190e21f0e5c805398449f9dad528dc50baaf9e3cce8b8158eb8ff74179be5733f8f
)
vcpkg_extract_source_archive(${ARCHIVE})
message(STATUS ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(USE_SHARED_LIBRARY OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(USE_SHARED_LIBRARY ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lcms RENAME copyright)

vcpkg_copy_pdbs()

#patch header files to fix import/export issues
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/shared.patch")
endif(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
