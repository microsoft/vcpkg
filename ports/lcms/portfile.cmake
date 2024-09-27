if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(SHARED_LIBRARY_PATCH "fix-shared-library.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF "lcms${VERSION}"
    SHA512 c0d857123a0168cb76b5944a20c9e3de1cbe74e2b509fb72a54f74543e9c173474f09d50c495b0a0a295a3c2b47c5fa54a330d057e1a59b5a7e36d3f5a7f81b2
    HEAD_REF master
    PATCHES
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
