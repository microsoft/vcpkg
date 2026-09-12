vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hellobertrand/zxc
    REF "v${VERSION}"
    SHA512 8a4d852a95fd9a9cb2f43a610c5dcde08c5cc9ad0af07734bd2c71651440224d489730a9b0306a0d337a241e683b2572df74679114fa43e0edc750a977a3e35f
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
        -DZXC_USE_SYSTEM_RAPIDHASH=ON
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
    # Upstream installs "unzxc" as a POSIX-only symlink to zxc that defaults to
    # decompression. Recreate it alongside the relocated tool (skipped on Windows).
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        file(CREATE_LINK "zxc" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/unzxc" SYMBOLIC)
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
