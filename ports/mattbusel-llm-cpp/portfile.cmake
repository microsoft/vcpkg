vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mattbusel/llm-cpp
    REF "v${VERSION}"
    SHA512 38bf5f064541020d5d21a5f8f7b304655c93ffc9f936a19bebd0e5fcf7ccf152e8b9f35fb9195279d0707085b68d614376e1e3b61ec309036d1d9193c34c55d6
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
if("curl" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pkgconfig/llm-cpp.pc" "Cflags:" "Requires: libcurl\nCflags:")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
