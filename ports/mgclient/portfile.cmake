vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memgraph/mgclient
    REF "v${VERSION}"
    SHA512 67321e51255c4552a8e9a4ad55a5ed9159b92ecea87f8a667bc817b87289940558f1f1cd0dc5f99bb698739bd5e1b58d9ff3f13c4d61190f27bd009b0055a445
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
