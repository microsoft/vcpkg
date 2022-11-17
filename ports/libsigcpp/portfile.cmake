vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF 3.2.0
    SHA512 95ab0acfc2c5a151335e73bdc9b0e058af67d9706d0697bfd938e38c51e853fdb29d7a26484f192abe150640c60d5e30075a23deaa043a8deed70616bc9f508a
    HEAD_REF master
    PATCHES 
        disable_tests_enable_static_build.patch
        fix-shared-windows-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME sigc++-3 CONFIG_PATH lib/cmake/sigc++-3)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/sigc++-3.0/include/sigc++config.h" "ifdef BUILD_SHARED" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
