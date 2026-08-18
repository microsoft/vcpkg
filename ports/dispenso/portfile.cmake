vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/dispenso
    REF "v${VERSION}"
    SHA512 074c5867c517fd4db79eaeb6b68e6efb4c5307bcaf3e76ff2c40102f7bf33d1635a4c01450863fd3e620654d9b6f38dd8d5be5b6432ddf51055396812a33a5c0
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISPENSO_BUILD_TESTS=OFF
        -DDISPENSO_BUILD_BENCHMARKS=OFF
        -DDISPENSO_USE_SYSTEM_CONCURRENTQUEUE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Dispenso-${VERSION}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
