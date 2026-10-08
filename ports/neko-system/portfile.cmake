vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoSystem
    REF v1.0.3
    SHA512 347fc13cabb7fd90f6cbcca2a025eb1bd6ae48fd80aeeb74ce1d58b8a5651d70605cfaf38a265b6ee6325a47b4f6eb2eec7b1332d692bafd71d0906898f84493
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNEKO_SYSTEM_BUILD_TESTS=OFF
        -DNEKO_SYSTEM_AUTO_FETCH_DEPS=OFF
        -DNEKO_SYSTEM_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoSystem PACKAGE_NAME nekosystem)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
