set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer-multiplexer
    REF "v${VERSION}"
    SHA512 24389efa834a8578e0f4e103e37d0d79a7738f5f88ca70bd4369b99f9518059d6a41ec19971bb1b0fcb5272d2a3ff361507cfc9cee66a2b85dcff8c2565e02cb
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
