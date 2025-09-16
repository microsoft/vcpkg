vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrew-gresyk/HFSM2
    REF ${VERSION}
    SHA512 e11559d174c633b474db706943eea3f8f011d1431908a4bab7f67324d42a3df426d10cf98b877c8f375e9a73efebce8559251d11049a10c0f9da574b8d016450
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
