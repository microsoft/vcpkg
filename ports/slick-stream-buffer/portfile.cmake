set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-stream-buffer
    REF "v${VERSION}"
    SHA512 d99d247993e23ead39f36806fdff91e085b5fcfbfe793ba59fa80e2b05f5879d19a9cfcf8849cf9621ea68be5fcb6b8e6b3b8d9db88fd5031c0b371d348c960a
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

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")