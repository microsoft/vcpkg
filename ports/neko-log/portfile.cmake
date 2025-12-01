vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoLog
    REF v1.0.6
    SHA512 acd86782fab0d3be5e1b4a4b54819b73018d9c14d2347a21d96e01fb2f7cf3641dc83b2363320d0564ad8cc77bb71ad6880dacc55aee8af77a04390d5f509d3c
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
