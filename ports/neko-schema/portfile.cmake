vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoSchema
    REF v1.1.4
    SHA512 2b246d62c25cf502a8c15d0d7ef2c23a6a2c3a3de5c1710e9720d9d95efff11ccd6d5e852bd7ff4eba0f3ecffb3d565381687d6af651fff22a845738032048dc
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_SCHEMA_BUILD_TESTS=OFF
        -DNEKO_SCHEMA_AUTO_FETCH_DEPS=OFF
        -DNEKO_SCHEMA_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoSchema PACKAGE_NAME nekoschema)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
