vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrew-gresyk/HFSM2
    REF ${VERSION}
    SHA512 a25bf93726917b215a0a10a65ece1553c3ac22275442ade8027387d4a2e87e35f8eed915133a01854a3f5082747b5832326f0abd1e5acf00086571dcd2b40ad1
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHFSM2_BUILD_TESTS=OFF
        -DHFSM2_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hfsm2 PACKAGE_NAME hfsm2)
vcpkg_fixup_pkgconfig()

# Remove empty directories if they exist
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")