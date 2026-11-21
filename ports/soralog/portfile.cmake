vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xDimon/soralog
    REF "v${VERSION}"
    SHA512 61136972b97678aae24c983ed1223f5ec6dce31c8b0ad2a17eb84892c7e52ad1ffbbdc8e457d1a1e3abc9dbcbb89712b760b4ef2062d59ccf377e1e9c20c21ff
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPACKAGE_MANAGER=vcpkg
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_BENCHMARK_COMPARE=OFF
        -DEXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
