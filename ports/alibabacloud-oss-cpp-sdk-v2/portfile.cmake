vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/alibabacloud-oss-cpp-sdk-v2
    REF "${VERSION}"
    SHA512 d5bc33e237dcf5a74327e35c4550e83eb7d8cf1ced7dbe82fc72bb46ea201dd7a069145711dfa4f949e21938178f712cac2e147114e7bd0d3fb307a38824d672
    HEAD_REF main
    PATCHES
        fix-unused-variables.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl        USE_CURL_TRANSPORT
        curl        USE_SYSTEM_CURL
        winhttp     USE_WINHTTP_TRANSPORT
        openssl     USE_SYSTEM_OPENSSL
        encryption  ENABLE_ENCRYPTION
        rtti        ENABLE_RTTI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME alibabacloud_oss_v2 CONFIG_PATH lib/cmake/alibabacloud_oss_v2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
    COMMENT [[Consult sdk/src/thirdparty/* in the original source tree for authoritative third-party notices.

As of 2026-06-09, vendored code under sdk/src/thirdparty includes:
- tinyxml2
- base64]]
)
