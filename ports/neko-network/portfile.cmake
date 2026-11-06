vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoNetwork
    REF v1.0.4
    SHA512 522523dbdfc189064c2abfc5cbe7aeadbf29abdd259169a6269bc06f1d31caa85e87b6f6eb4b2f95866c4a0ded03e0bbb0872d14fbef4cddda04119d6b21b2d1
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
