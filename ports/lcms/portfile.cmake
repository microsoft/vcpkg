include(vcpkg_common_functions)

vcpkg_from_github( 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO mm2/Little-CMS
    REF lcms2.8
    SHA512 22ee94aa3333db4248607d8aa84343d324e04b30c154c46672c6f668e14a369b9b72f2557b8465218b6e9a2676cf8fa37d617b4aa13a013dc2337197a599e63a
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
