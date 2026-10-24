vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EreliaStudio/Sparkle
    REF "sparkle-v0.1.3-g5117c64a7052457ca2de1864bf23e0e29487bdcf"
    SHA512 66d7432276d3d0ccb30f1297d187c0b230e5b6fbdec6ae8b07534f1e9b2b4f4d01fb021f30001f1abae04ca8b54d4ec3b597d054f2adf30c8d4f35220185128c
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS SPARKLE_FEATURE_OPTIONS
    FEATURES
        graphics SPARKLE_BUILD_GRAPHICS
        test-library SPARKLE_BUILD_TEST_LIBRARY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${SPARKLE_FEATURE_OPTIONS} -DSPARKLE_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME sparkle
    CONFIG_PATH lib/cmake/sparkle
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/resources/fonts/LICENSE-Liberation.txt"
)
