set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Krasnovvvvv/yandex-disk-cpp-client
        REF v1.0.4
        SHA512 93a142d5bce93fe9f751decede2dfd715f5f21cd72f716a58b16202483cab8fdc4102f558e738864e1ac57e941e95d62ba4af6a9b60a89c1bdb72e8ffe24dd88
        HEAD_REF main
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DBUILD_EXAMPLES=OFF
            -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
        PACKAGE_NAME "yandex-disk-cpp-client"
        CONFIG_PATH "lib/cmake/yandex-disk-cpp-client"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")