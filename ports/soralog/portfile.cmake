vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xDimon/soralog
    REF "v${VERSION}"
    SHA512 75c72bd4491c0d6d794de8ee3a975f8b47f3309787353e4eb1916bdad093a3746f5786e04380dc65a9e3caf8514e9dc755c2be4c3e36ee6c62b4f4b87998fba1
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
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
