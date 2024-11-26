set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bw-hro/TempDir
    REF "v${VERSION}"
    SHA512 75c271b9f84c8eb9256a99683828faecd17f86b9c7a9066266157bf2d10acfe2d057470295b2dc05dbad5cc6fb1d6af60aed2924fba391c0bc292afc37d9e1ea
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
