vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wgois/OIS
    REF v1.5.1
    SHA512 20598aef999a70900cb7f75ffaf62059acf8e811822971cb21986b5d25d28dacb79e4b4cf4770c70e00d3c55cdd01ef3e68a77c2dd148677784fc4df38891340
    HEAD_REF master
    PATCHES
        0001_install_pkgconfig_win32.patch
        0002-fix-cmake4.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Include files should not be duplicated into the /debug/include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
