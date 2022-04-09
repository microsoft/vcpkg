vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openexr/openexr
    REF v3.1.4
    SHA512 612ab3467f9ccf2779e1592361cb07459571122e10c0a0b3020430cfa34fa3b91ca1d63cc12a5f85d5b53b277b3f7a88862e6477f0f3566a4196b8245f6bfe12
    HEAD_REF master
    PATCHES
        remove_symlinks.patch
        fix_msvc_2022_build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=_d
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenEXR)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_pkgconfig()
endif()

vcpkg_copy_tools(
    TOOL_NAMES exr2aces exrenvmap exrheader exrinfo exrmakepreview exrmaketiled exrmultipart exrmultiview exrstdattr
    AUTO_CLEAN
)

vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
