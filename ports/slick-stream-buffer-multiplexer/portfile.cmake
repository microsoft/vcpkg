set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer-multiplexer
    REF "v${VERSION}"
    SHA512 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34
    HEAD_REF main
    PATCHES
        slick-dependencies-fetching.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_STREAM_BUFFER_MULTIPLEXER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-stream-buffer-multiplexer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
