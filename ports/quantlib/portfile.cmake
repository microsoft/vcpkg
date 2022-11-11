vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF QuantLib-v1.28
    SHA512 720bc18e5a01367e5cea5c9a28f2103357e6d2708dbc13c208a73b52bc615ba03ab248eca75f94e9c7631e340faa87a18bef94b4ae9f277006fc62fac4b30bc4
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
