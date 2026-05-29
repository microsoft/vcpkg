vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memgraph/mgclient
    REF "v${VERSION}"
    SHA512 870b15691f394fad894ea5b38f138eb6ae8788d3a3c19eb89d12a86ffb36546f99b24ded88a65e44e479d22220e8dc3262a4121d5a4d88be8ef6a481282d28a9
    HEAD_REF master
    PATCHES
        export-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        cpp    BUILD_CPP_BINDINGS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DBUILD_TESTING=OFF
        -DBUILD_TESTING_INTEGRATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mgclient)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
