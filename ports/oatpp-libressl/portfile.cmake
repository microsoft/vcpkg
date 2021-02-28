set(OATPP_VERSION "1.2.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# get the source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-libressl
    REF cd2e9a515131e5e7dc043c591e952e12cd63db2c # 1.2.0
    SHA512 e6d208edddff5373c07887b76fc808733bd363c340e740047ae90317874b73a5ef71e5cbbb0f9b1b48632c7a78709858a5ff0de81bc39207961e3642c0104010
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
