vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wgois/OIS
    REF v${VERSION}
    SHA512 f9145d632d4cb0f23199be803aa0847d7d339c739e4a0c8f733e121c51a28e72254285416810271bf164b3447097a26ca55a05e1547b30078d19669c7e84445f
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
