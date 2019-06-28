include(vcpkg_common_functions)

vcpkg_from_github( 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO mm2/Little-CMS
    REF lcms2.9
    SHA512 b565ed3714c9beaf13e15b3798abbc6c295443357c8db3299cecd9794620bb1d7c50ad258cf887c7bbf66efacb8d8699a7ee579f8c73598740915caa3044ae70
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/remove_library_directive.patch"
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
