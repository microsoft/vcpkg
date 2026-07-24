vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memgraph/mgclient
    REF "v${VERSION}"
    SHA512 0c4c0b1231f3f5e232ef9a80a01a58e00d2d50dc1e7bb4a6c25d800c93d7f77b8b21679af9ce26fc98a54813c54fac0a5e7eb8eb9a0eb78dbd88ce1ad569a2e2
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
