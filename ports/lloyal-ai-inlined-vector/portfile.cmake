set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lloyal-ai/inlined-vector
    REF "v${VERSION}"
    SHA512 619777f8dd930813e5be96cdfa5171485356fb8ac6ed3f32fca3ad68565a48c269a38a022d734b118c0e397f5f84ad591a27c42b7080616af5d7d0575e6a7a9b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINLINED_VECTOR_BUILD_TESTS=OFF
        -DINLINED_VECTOR_BUILD_BENCHMARKS=OFF
        -DINLINED_VECTOR_BUILD_FUZZ_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/inlined-vector/cmake)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
