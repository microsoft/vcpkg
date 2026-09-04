vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memgraph/mgclient
    REF "v${VERSION}"
    SHA512 c3f897f48907d2e163c032d046b74d83218e1621d2929eb2e3688aa21d679c35b2720a309f51b984b13f5326d306e91b2d290da9684aa1ed165d8576576970f9
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
