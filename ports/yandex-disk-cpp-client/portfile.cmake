set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Krasnovvvvv/yandex-disk-cpp-client
        REF v1.0.3
        SHA512 de0e68aa0419f9918afea9fa7741477941d63c21e08cbe50d27a5fe9de7160a7a1f5ce4d307c906001aa757f82951295189c5d213b788987449d1a1b102da945
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
