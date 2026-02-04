vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoThreadPool
    REF "v${VERSION}"
    SHA512 143e4bd8ca900a6a1680e62144ce39c8426057ed2b7f8b53267eb388fa54c2f7cca7e1e587b866e7f7e22759102765224217ecd083e406497d49f4a8600acccb
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_THREAD_POOL_BUILD_TESTS=OFF
        -DNEKO_THREAD_POOL_AUTO_FETCH_DEPS=OFF
        -DNEKO_THREAD_POOL_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoThreadPool PACKAGE_NAME nekothreadpool)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

