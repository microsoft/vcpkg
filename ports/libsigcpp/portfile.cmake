vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF 3.0.7
    SHA512 4c9251613c30cc5d455dc30a039a12b73d6369ac03583dab382307b894f93d4733cebea0a6eef82e8d80b1354c812b4ff6bfc68913f0df5a61146d56a6afde13
    HEAD_REF master
    PATCHES 
        disable_tests_enable_static_build.patch
        version.patch
        fix-usage-in-static-build.patch
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
