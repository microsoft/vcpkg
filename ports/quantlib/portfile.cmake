vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF QuantLib-v1.27
    SHA512 c763e7083e1e832d39adb507cc6b34b1ad0a0b7f2b7ffe390428f93fb1df84fcbbf43bcb31dd2f2381da2ac563c88a10fbd932ea5155bd43c604025960039b58
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
