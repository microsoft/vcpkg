# soralog.dll has no code of its own: it only links the other soralog libraries
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xDimon/soralog
    REF "v${VERSION}"
    SHA512 d094173937235cd2f8df891cef72b9da871a9197ac54d79dd68820ed158255f0258aa88dc424c1c1c46151311867b66075a113993e6d7478c940ed2a6c09b6c1
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
