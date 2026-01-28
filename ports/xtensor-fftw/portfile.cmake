# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-fftw
    REF "${VERSION}"
    SHA512 278676eb92767677622bac961b65be599804ea86eba4df4cd72f237f9c9f8f2d20b7daec045bde6c09d7c72e29f5c5e01e6abda7350ac706543f34434c8d40f2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMPILE_WARNINGS=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DBENCHMARK_ENABLE_TESTING=OFF
        -DDEFAULT_COLUMN_MAJOR=OFF
        -DCOVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
