vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RippeR37/libbase
    REF "v${VERSION}"
    SHA512 5bbb6758db694ed899d1181c9dc1ad6f90a55f73c8fb6d05f179695c4cc5e3354989d85879651781a34e6bbd396afe8c8f5fb406a24280e579142618923fc9af
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
