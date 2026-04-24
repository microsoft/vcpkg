vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hellobertrand/zxc
    REF v${VERSION}
    SHA512 528d7c1101039eac3214dc67fa7f758a2c4bb1d47a2ed2d69072ada7d920cbcf6d986673fa94b9f60fe3f91a89c24a545d72ad1654e4826cd100cacb2ae95497
    HEAD_REF main
)

# Remove vendored rapidhash to use the rapidhash port instead
file(REMOVE "${SOURCE_PATH}/src/lib/vendors/rapidhash.h")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        util ZXC_BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DZXC_NATIVE_ARCH=OFF
        -DZXC_ENABLE_LTO=OFF
        -DZXC_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zxc)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if ("util" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            zxc
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
