set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Krasnovvvvv/yandex-disk-cpp-client
        REF v1.0.1
        SHA512 6edbcbb793475e8b90ed33793dc9f0d092a4ad86290010afbf6839adc494bb712a939f651440cb55d315d7f4650437df132e64fdb241a3a8f3ba196b0a8d3332
        HEAD_REF main
)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        PACKAGE_NAME "yandex_disk_client"
        CONFIG_PATH "lib/cmake/yandex_disk_client"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
