vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 fc45f2ce0bf752313369786b65b92443ef6d9ed7e264e22cfe2a4732b370f6bb6e5573b646d0e8edf1b0bf9b9bc5137c98aed5929ba75acdf157d2764bd838fa
    HEAD_REF master
    PATCHES
        remove_library_directive.patch
        ${SHARED_LIBRARY_PATCH}
        remove-register.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME lcms2)
vcpkg_cmake_config_fixup() # provides old PACKAGE_NAME lcms
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/lcms/lcms-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(lcms2 CONFIG)
include(${CMAKE_CURRENT_LIST_DIR}/lcms-targets.cmake)
]])

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
