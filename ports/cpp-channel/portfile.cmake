vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andreiavrammsd/cpp-channel
    REF "v${VERSION}"
    SHA512 2fc92f683c273f1f6d9aa45544a0997bbe5f9143c886e0051789986702e8bd6d7d3c34fa3a488ffe93f91a1cb49af7e4d59234c2226d3d05dd09a0fabeaf1985
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
