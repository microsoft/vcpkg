set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/TempDir
    REF "v${VERSION}"
    SHA512 bae89ee0e5d3df75d23d83865e5c2d7a9fdb82ee4b8fead11ea89e7fc032c789e257411ff82d2de3d15b8a9947fdfcb98050531d7b0b5c20b4f8f247c6d11de0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTD_BUILD_EXAMPLES=OFF
        -DTD_BUILD_TESTS=OFF
        -DTD_ENABLE_COVERAGE=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
