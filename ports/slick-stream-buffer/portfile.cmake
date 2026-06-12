set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer
    REF "v${VERSION}"
    SHA512 756201be1df980c7281a15684fbef96bb7caaf1412aa5b1e4e353fc06e2f7ea99ae383216275bcd33fbfc24d190c3a2bc25bcbe122a174da21099e5b1dec46ba
    HEAD_REF main
    PATCHES
        slick-shm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_STREAM_BUFFER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-stream-buffer
    CONFIG_PATH lib/cmake/slick-stream-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")