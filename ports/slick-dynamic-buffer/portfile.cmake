set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-dynamic-buffer
    REF "v${VERSION}"
    SHA512 2c321991d725fb9e65d23805359e4455c06c07f46850abd38e35a9471ecf994888e307fa5c6a2a8685247e5f9195d3a25c1a59b4eed4a78c4d39d733f6c7ac8a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_DYNAMIC_BUFFER_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-dynamic-buffer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
