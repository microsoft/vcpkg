set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer-multiplexer
    REF "v${VERSION}"
    SHA512 ce3fdfb24ea5b9b1ac3e6598570e71bbd5a794807f217203ae2d1a66a73c6872b5c4038a92b8946b7c1c9b91effe1de8c79a9242ff8c1e6d298d494ebcecbeca
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
