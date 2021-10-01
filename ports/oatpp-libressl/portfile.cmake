set(OATPP_VERSION "1.2.5")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# get the source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-libressl
    REF ${OATPP_VERSION}
    SHA512 64b596576b7c976cd8ebd68ba16a38e7b9c65794d9dcea82d3537d2433f11645a25eb567aea6d16ddc51f8ff5f90e83f29e24555c3ae87f80883ec2f53366d99
    HEAD_REF master
    PATCHES "libress-submodule-downgrade-required-libressl-version.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DLIBRESSL_ROOT_DIR=${CURRENT_INSTALLED_DIR}"       
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-libressl-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
