set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/webthing-cpp
    REF "v${VERSION}"
    SHA512 f4b854d9d363c4b3590232da31a150b3b4a3fb9150cd32558240b02ccf9c8453e79d2330c04076332927c5d488cc5b09ff28a40f225af21f52bd1eac7a4c421a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl   WT_WITH_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWT_BUILD_EXAMPLES=OFF
        -DWT_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
