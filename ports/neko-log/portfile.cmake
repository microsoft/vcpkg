vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoLog
    REF "v${VERSION}"
    SHA512 e64e01511dd77da3cfd648ac31911bd3ddda189817b818880568b80726d4ef2c7d118807164c4b18671e5d301a5c38f99209b66c030347d7d9c731497ff6c9a4
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_LOG_BUILD_TESTS=OFF
        -DNEKO_LOG_AUTO_FETCH_DEPS=OFF
        -DNEKO_LOG_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoLog PACKAGE_NAME nekolog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
