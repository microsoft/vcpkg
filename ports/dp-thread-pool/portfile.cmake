set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DeveloperPaul123/thread-pool
    REF 517e39f02207c4a0d227c77f0bc1cfb0518044be
    SHA512 2910719a056c46b6db66063674ae3a4895a48a58d88398a03934d3431dac855ac324551cac48dd0b5a77b56a6525502543adef26ac24ea779a0289233019102d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTP_BUILD_TESTS=OFF
        -DTP_BUILD_EXAMPLES=OFF
        -DTP_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME thread-pool
    CONFIG_PATH lib/cmake/thread-pool-${VERSION}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
