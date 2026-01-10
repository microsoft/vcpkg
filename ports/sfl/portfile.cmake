vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slavenf/sfl-library
    REF "${VERSION}"
    SHA512 0a4369c34f1b2a9becb3ae9e7d931f37ba0185d2283c3dd773224ddcccd8f09d7c2bf5b4a71f8a8f55a679f0d34499d0a1477d93f830570c5be4ab0377abedb2
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
