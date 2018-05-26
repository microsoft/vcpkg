include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "ANGLE currently only supports being built as a dynamic library")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "ANGLE currently only supports being built for desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF 8d471f907d8d4ec1d46bc9366493bd76c11c1870 
    SHA512 b4670caeeaa5d662bc82702eb5f620123812ea6b5d82f57a65df54ae25cdaa5c9ff0fdb592448b07569d9c09af3d3c51b0b2f135c5800d1845b425009656bf18
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
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-angle)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/angle ${CURRENT_PACKAGES_DIR}/share/unofficial-angle)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angle RENAME copyright)
