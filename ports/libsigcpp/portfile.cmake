vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF "${VERSION}"
    SHA512 8fc90594fe161a4fd82b88fe4b0cb5b667d61712dae47982ba569775b4a855e03d4b30d3ba232f96e6a98f87473f7c9d4948b7a17a3f9ca2da547f95b6f91a40
    HEAD_REF master
    PATCHES
        disable_tests_enable_static_build.patch
        fix-shared-windows-build.patch
        fix_include_path.patch
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
