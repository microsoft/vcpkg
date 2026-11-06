vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 1c2d2497421b9a9a7813bfbca301389a99b2b83974e8a86c8694d3259983dbd627f83885586fa81a74870ede42e0a3c99a0dc32615ac624c28c0c28b29a50c77
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
