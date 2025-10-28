set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lloyal-ai/inlined-vector
    REF "${VERSION}"
    SHA512 45cb97f18053fa3079b4014cdcd5f4ecb1c508ec30160baf04026934e43cf18e67688d70f5499147a208685fcdace587455555a3696ce3aeecf5bc99257d3fc7
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/inlined-vector)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
