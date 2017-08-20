include(vcpkg_common_functions)

vcpkg_from_github( 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO mm2/Little-CMS
    REF lcms2.8
    SHA512 ad904ce8acead6c8e255feb8386c1ab3fa432c3b36a3b521bc5c50993cb47ce4d42be0ad240dd8dd3bfeb3c0e884d8184f58797da5ef297b2f9a0e7da9788644
    HEAD_REF master 
) 

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
endif()
