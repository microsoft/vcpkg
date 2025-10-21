set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Krasnovvvvv/yandex-disk-cpp-client
        REF v1.0.2
        SHA512 a020f997063bff09f1962141fd9a69c6f7b564e25ffbb5f9de06a72b08054810578ecf48efe420c94327cfb2c65f1f5b2dde37dc6e03beb9a0ab5eba85a2d170
        HEAD_REF main
)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        PACKAGE_NAME "yandex-disk-cpp-client"
        CONFIG_PATH "lib/cmake/yandex-disk-cpp-client"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

