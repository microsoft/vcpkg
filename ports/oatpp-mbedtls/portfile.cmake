if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-mbedtls
    REF ${VERSION}
    SHA512 3eea805f2a02110daec25b7455543c59d8e72acd37d412fa98cb1c90f58e4edcd9cc62c16331efcca36a524834fa0f314f2f69a7a4d0d1108a758f811a68e021
    HEAD_REF master
    PATCHES
        find-mbedtls.patch
        mbedtls-3.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"   
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/oatpp-mbedtls-${VERSION}")
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ "${CURRENT_PACKAGES_DIR}/share/oatpp-mbedtls/oatpp-mbedtlsConfig.cmake" cmake_config)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/oatpp-mbedtls/oatpp-mbedtlsConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(oatpp CONFIG)
${cmake_config}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
