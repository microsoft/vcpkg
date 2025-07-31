vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 e31ee88bdfbd345cfe3af8372e6fcb04ea9e4de62f8c0a0061780e2ad4edc89f3dfa0af8af2024a621481cc1ef3218f116012b33eadda84e3d688d8c354c74bb
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
