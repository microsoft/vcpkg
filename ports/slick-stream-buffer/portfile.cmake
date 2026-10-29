set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer
    REF "v${VERSION}"
    SHA512 4de4a041434381fa28b9143992a6bd95dee07e6f14075a0ec8044a22b21f2406a6ead60463ad20ea2c71855dcab488cdf6bd35eab12def8a96774460aa2d380f
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
