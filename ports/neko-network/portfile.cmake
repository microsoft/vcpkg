vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoNetwork
    REF v1.0.3
    SHA512 394bcd82743c25c1954dcce6699bc0c13a2ac8f00b06d082659aface2d6efeccb736feaa5c94a4eef2789194f2d7adefae0c476bf27866547be48602c90226b5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_NETWORK_BUILD_TESTS=OFF
        -DNEKO_NETWORK_AUTO_FETCH_DEPS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoNetwork PACKAGE_NAME nekonetwork)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
