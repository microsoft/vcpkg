vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoNetwork
    REF v1.0.5
    SHA512 d8c45a67950e39ffec03f346b1d8d39d8923f68937c2aff4fc4cc360e1a3d6836d367fd807f3a94566ef540d59d94216b774d3ac240ede57e0f6a5a26f5749f3
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        nlog NEKO_NETWORK_ENABLE_NLOG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_NETWORK_BUILD_TESTS=OFF
        -DNEKO_NETWORK_AUTO_FETCH_DEPS=OFF
		${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoNetwork PACKAGE_NAME nekonetwork)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")