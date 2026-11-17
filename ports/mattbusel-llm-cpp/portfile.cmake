vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mattbusel/llm-cpp
    REF "v${VERSION}"
    SHA512 51c5d26ee6006904f7a20a01f9eb89abf69f3b2d20ac30d34618960fd5dac9b2f2ed6ad9547eba4b5d05fc64c977a0179d19951fb0721cfbf0055d7bec66d8a9
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
