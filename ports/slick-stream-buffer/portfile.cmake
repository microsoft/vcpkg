set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer
    REF "v${VERSION}"
    SHA512 89a381c9e8a848400291a2c27b266c09a35a158ac4194d7af25fb5a333f3bcb044277117685ff00afbc733a10c6d76ab7eeb23d60ef4a818516086fe2f6487ab
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_STREAM_BUFFER_TESTS=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_slick-shm=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-stream-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
