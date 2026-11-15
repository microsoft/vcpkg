vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mattbusel/llm-cpp
    REF "v${VERSION}"
    SHA512 6f4ca6ccec209125e585307e98b9cf280ee1db68684d707ce1bc0260c74f0849b5c36f015a707682b4d466f0787a1eb1007350ae922ab97e6dea98729322ae46
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
