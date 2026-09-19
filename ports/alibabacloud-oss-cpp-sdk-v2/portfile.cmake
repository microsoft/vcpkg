vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aliyun/alibabacloud-oss-cpp-sdk-v2
    REF "${VERSION}"
    SHA512 e50229d8db547b779a706810b4e4fc7aca6cf2ec0e7bbe54f14add79c5545dff121224093906efca38c70a7c7ac7b5d3f910aa53280d0072473d21a74f7b18ed
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl        USE_CURL_TRANSPORT
        curl        USE_SYSTEM_CURL
        winhttp     USE_WINHTTP_TRANSPORT
        openssl     USE_SYSTEM_OPENSSL
        encryption  ENABLE_ENCRYPTION
        rtti        ENABLE_RTTI
        tinyxml2    USE_SYSTEM_TINYXML2
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/THIRD_PARTY_NOTICES")
