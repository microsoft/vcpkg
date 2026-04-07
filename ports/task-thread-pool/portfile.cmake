set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alugowski/task-thread-pool
    REF v${VERSION}
    SHA512 9ab656fe75dcdafa1fee3fe3d227e8302628894b8dc7d65f80f5d28e7b989dfe299f4f1b5d9c179f238b46b60315fc0be0ff30fdbde570c5709cf2fa4251042e
    HEAD_REF main
    PATCHES
        fix-header-file-path.patch
        find-threads.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTASK_THREAD_POOL_TEST=OFF
        -DTASK_THREAD_POOL_BENCH=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME task_thread_pool CONFIG_PATH share/cmake/task_thread_pool)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-BSD.txt" "${SOURCE_PATH}/LICENSE-Boost.txt" "${SOURCE_PATH}/LICENSE-MIT.txt")
