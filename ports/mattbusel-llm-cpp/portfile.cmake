vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mattbusel/llm-cpp
    REF "v${VERSION}"
    SHA512 e0a4637e5ade3cf3fa3a3046a5625be5f1d1f7e36f59e915ab6a72d51e262f8d2294d7fe170e86ff1eee2b2ae0939edd93f00ed296a21e010eb96a88d894eb11
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl VCPKG_LOCK_FIND_PACKAGE_CURL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLLM_CPP_BUILD_TESTS=OFF
        -DLLM_CPP_BUILD_EXAMPLES=OFF
        -DLLM_CPP_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME llm-cpp CONFIG_PATH share/llm-cpp)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
