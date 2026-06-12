set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer
    REF "v${VERSION}"
    SHA512 bd940b4077385ecf00fff11d551a59fd6fd948eb96e6e8d36c8226d2e9f960c677699a8ca2cb5233ea445d622e5dded6cc67365a8632f9e58f9a9ffd83a6a8b7
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
