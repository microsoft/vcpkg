vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 fe9f7adab569eb34b5a74b87f88f4bfaae8f555f87ec082b0960e748a18e722b5759fcc4a9c0604782fab24413dd813eb2a6dce5dd29263d8300128195788064
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
