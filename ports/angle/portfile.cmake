include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "ANGLE currently only supports being built as a dynamic library")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF efe061bd4f9de0f8da3135bcabff7f40e05e91f7 
    SHA512 0fdd8d4149fb0b75edd9d408732176bc8f7a2c2000abb9d3d783e96e88bf1ec52fe9aa0bf1d24a7fdb3a07f00975a2a7058e724b0fd70b71baf495d45ca492a2
    HEAD_REF master
)
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-fix-uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/commit.h DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}    
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-angle)
#file(RENAME ${CURRENT_PACKAGES_DIR}/share/angle ${CURRENT_PACKAGES_DIR}/share/unofficial-angle)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angle RENAME copyright)
