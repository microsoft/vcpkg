vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RippeR37/libbase
    REF "v${VERSION}"
    SHA512 af360ec0c0181f711ee66fd7157d5e8dc38f5d78df97bce4ff4cb2c4d8ef270e76b0254be4f920eee74a0026845f805955a208b76f48ca38ba925169e4f05e03
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        net LIBBASE_BUILD_MODULE_NET
        win LIBBASE_BUILD_MODULE_WIN
        wx  LIBBASE_BUILD_MODULE_WX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBBASE_OUTPUT_NAME=ripper37-libbase
        -DLIBBASE_CODE_COVERAGE=OFF
        -DLIBBASE_BUILD_DOCS=OFF
        -DLIBBASE_CLANG_TIDY=OFF
        -DLIBBASE_BUILD_EXAMPLES=OFF
        -DLIBBASE_BUILD_TESTS=OFF
        -DLIBBASE_BUILD_PERFORMANCE_TESTS=OFF
        -DLIBBASE_BUILD_ASAN=OFF
        -DLIBBASE_BUILD_TSAN=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libbase"
    CONFIG_PATH "share/libbase"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
