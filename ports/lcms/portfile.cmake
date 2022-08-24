if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ADDITIONAL_PATCH "shared.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mm2/Little-CMS
    REF 924a020d09bfe468c665467caf24aadeb41ff77c # 2.12
    SHA512 0c2dc069878ca38a92af4800aa3fb2660203fbcdf6dccd9db60cfacb6896185e3e9222893f39ec3e132b0f4900a2932d490dd8db5b1b431519966a64d28404d2
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
