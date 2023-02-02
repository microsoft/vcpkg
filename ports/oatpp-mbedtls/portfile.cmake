set(OATPP_VERSION "1.3.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-mbedtls
    REF ${OATPP_VERSION}
    SHA512 3eea805f2a02110daec25b7455543c59d8e72acd37d412fa98cb1c90f58e4edcd9cc62c16331efcca36a524834fa0f314f2f69a7a4d0d1108a758f811a68e021
    HEAD_REF master
    PATCHES find-mbedtls.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"   
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp-mbedtls CONFIG_PATH lib/cmake/oatpp-mbedtls-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
