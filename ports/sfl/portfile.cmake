vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 eb480dfe89f5f3558b6470d6ded49cdccc6b2f68ca1a6b0b87d80ae6fb427e500d4cc95afdedc3c932b8051c5f1751f484996c8263e4ab3f5543c663a90daacb
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
