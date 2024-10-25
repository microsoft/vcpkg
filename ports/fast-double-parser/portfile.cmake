set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/fast_double_parser
    REF "v${VERSION}"
    SHA512 41115f3c3b77ad430b0b4a1e622dd2a911ce3283bfd4190b5081f368cd1c371c68cf49789a12a2ed610a91e5b4693fe0b9b0d07876e82cfb0b106a6bc33dedd0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME fast_double_parser)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
