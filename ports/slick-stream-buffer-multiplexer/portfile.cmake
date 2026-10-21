set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer-multiplexer
    REF "v${VERSION}"
    SHA512 767afff658aa57ec14df5e62bfe8c313e9c1383f939bfa96130e3d38bdac99f7e1dbeae578840ba6dc401ce9dd2bac146351c1fdb6682ad22ad8f723c64400d4
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
