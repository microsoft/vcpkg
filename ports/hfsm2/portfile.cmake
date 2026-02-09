vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrew-gresyk/HFSM2
    REF ${VERSION}
    SHA512 4effd662b63765b9f4a194bb1efe92e5f3b69e96bda8dc78dfa86698ab9ddc33d2d7079d22d278311b47691f59605a0980cf49b33c9d3b2e884e2d74067d1b56
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
