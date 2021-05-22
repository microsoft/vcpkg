set(OATPP_VERSION "1.2.5")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-mbedtls
    REF ${OATPP_VERSION}
    SHA512 ffc7ef3614a4b3ef44c61af3db8c5b5a75ecc657b2f9f5ade4f9e78260427ca113be700065b6fcdc3e6f553648601fe4d8c68a54e10234949e004f40def0d343
    HEAD_REF master
    PATCHES find-mbedtls.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"   
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-mbedtls-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
