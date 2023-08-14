vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF "v${VERSION}"
    SHA512 37147f7180b09ab2cfc49400255ffab470e5f3b07cf8eade0f9fe2b20a6bbc3c5c75deeb3b6beca698f62abb2114075fb4e70e43ef936028b9e30f6338dac785
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS)
    # This can (and should) be removed if QuantLib ever supports dynamically linking on Windows
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQL_BUILD_BENCHMARK=OFF
        -DQL_BUILD_EXAMPLES=OFF
        -DQL_BUILD_TEST_SUITE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME QuantLib CONFIG_PATH lib/cmake/QuantLib)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
