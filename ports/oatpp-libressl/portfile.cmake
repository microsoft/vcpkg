set(OATPP_VERSION "1.3.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# get the source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-libressl
    REF ${OATPP_VERSION}
    SHA512 8f16c4e0341dc20e4a8a5fcdcf8e58bac1cfbef51b8cac6f5ca4894acf296333fcc2b8f34c6353cbd31a1f2f2be021550ce859489a45f388f4b5ccec4c67eee9
    HEAD_REF master
    PATCHES "libress-submodule-downgrade-required-libressl-version.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DLIBRESSL_ROOT_DIR=${CURRENT_INSTALLED_DIR}"       
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp-libressl CONFIG_PATH lib/cmake/oatpp-libressl-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
