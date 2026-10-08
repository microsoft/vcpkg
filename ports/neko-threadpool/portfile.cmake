vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoThreadPool
    REF v1.0.3
    SHA512 d3d09662d9e92637482e5612790b73dd1a98265f54cc5f07532da6a94a96a3e4807ce759f2f05bc3d45dbd584ac57ae485ce9e5f0eccf2bd0c9a097fa2b1a858
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
