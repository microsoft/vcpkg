vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/units
    REF "v${VERSION}"
    SHA512 b0c40248a25adff97d3bd6eb6899bf7ed9a4622857a6eb0d62d040db6e60141fac201362710bbe417d8c284adcec89f8742815fcf17f30557e822d8f4e08fc4e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNITS_CMAKE_PROJECT_NAME=LLNL-UNITS
        -DUNITS_ENABLE_TESTS=OFF
        -DUNITS_BUILD_FUZZ_TARGETS=OFF
        -DUNITS_ENABLE_ERROR_ON_WARNINGS=OFF
        -DUNITS_ENABLE_EXTRA_COMPILER_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME llnl-units CONFIG_PATH lib/cmake/llnl-units)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
