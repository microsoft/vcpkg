if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ADDITIONAL_PATCH "shared.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF e88d9bcad79b7ebf6b97ebd634af31ed23c1b910 # 2.14
    SHA512 29cc2bd6b41939d424a0893c4cca5323a50ed16efd48f03e42e0e1dd27ad9144050b0c20ac56a1174e0ca0e043151f44b77a2f0181a233dd7da0aef9b51a9d41
    HEAD_REF master
    PATCHES
        remove_library_directive.patch
        ${ADDITIONAL_PATCH}
        cpp17.patch
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
