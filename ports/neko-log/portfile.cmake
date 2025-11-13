vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoLog
    REF v1.0.2
    SHA512 C0DAEE8EBC49568AB4CB8D2650C3B0AE09B66A255D356F15FE4D760ABDE0A1B01C3ABB5F03E2BD69A36CB9D3A02CA7CDC7C31A537FAEF2A36FA4F8DFDDB57B25
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tests   NEKO_LOG_BUILD_TESTS
        module  NEKO_LOG_ENABLE_MODULE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    # Before NekoSchema is available, automatically fetch dependencies via FetchContent
        -DNEKO_LOG_AUTO_FETCH_DEPS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoLog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
