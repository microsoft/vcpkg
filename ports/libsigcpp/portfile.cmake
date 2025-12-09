vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF "${VERSION}"
    SHA512 0d22275995a1629ae73b0cc2b2f2598b18aa0ed6d35bd3f1735a50f54d356fb248dedc8d9b5f2794830866b04e0f58ce641048e2df7215ec2e6eac744de58a27
    HEAD_REF master
    PATCHES
        disable_tests_enable_static_build.patch
        fix-shared-windows-build.patch
        fix_include_path.patch
        fix_version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME sigc++-3 CONFIG_PATH lib/cmake/sigc++-3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sigc++config.h" "ifdef BUILD_SHARED" "if 1" IGNORE_UNCHANGED)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
