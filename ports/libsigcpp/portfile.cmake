vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF "${VERSION}"
    SHA512 39c63131fdde701c08accc0bc318435fba65a01593f97d6fa61ad356a6a3441610810107fb7aded7b3ef48e34a603e513a43cf8c36a57d2286f54d41ead412c6
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sigc++config.h" "#ifdef SIGC_DLL" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sigc++config.h" "#ifdef SIGC_DLL" "#if 0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
