vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andreiavrammsd/cpp-channel
    REF "v${VERSION}"
    SHA512 143f6872dc0388e18605374a4daa9857abe27a68904aef6661b2d0dbb25f59f4e3f139ae537b041b8990b225b6ef7a9f72e645d28a4926c9b015d03ea4395c66
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPP_CHANNEL_BUILD_TESTS=OFF
        -DCPP_CHANNEL_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
